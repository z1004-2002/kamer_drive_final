import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/unified_history_item_model.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UnifiedHistoryItem> _clientHistory = [];
  List<UnifiedHistoryItem> get clientHistory => _clientHistory;

  List<UnifiedHistoryItem> _ownerHistory = [];
  List<UnifiedHistoryItem> get ownerHistory => _ownerHistory;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<void> fetchUserHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      final rentClientSnap = await _firestore
          .collection('rental_bookings')
          .where('tenantId', isEqualTo: uid)
          .get();
      final saleClientSnap = await _firestore
          .collection('sale_bookings')
          .where('buyerId', isEqualTo: uid)
          .get();

      final rentOwnerSnap = await _firestore
          .collection('rental_bookings')
          .where('ownerId', isEqualTo: uid)
          .get();
      final saleOwnerSnap = await _firestore
          .collection('sale_bookings')
          .where('ownerId', isEqualTo: uid)
          .get();

      List<UnifiedHistoryItem> tempClient = [];
      List<UnifiedHistoryItem> tempOwner = [];

      Future<UnifiedHistoryItem?> buildItem(
        DocumentSnapshot doc,
        String type,
        bool isMyListing,
      ) async {
        final data = doc.data() as Map<String, dynamic>;
        final vehicleId = data['vehicleId'];

        final vehicleDoc = await _firestore
            .collection('vehicles')
            .doc(vehicleId)
            .get();
        if (!vehicleDoc.exists) return null; // Si le véhicule a été supprimé
        final vData = vehicleDoc.data()!;

        String dateInfo = "";
        double price = 0;
        String clientId = "";

        if (type == "Location") {
          final start = DateTime.parse(data['startDate']);
          final end = DateTime.parse(data['endDate']);
          dateInfo =
              "${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}";
          price = (data['totalPrice'] ?? 0).toDouble();
          clientId = data['tenantId'];
        } else {
          final created = DateTime.parse(data['createdAt']);
          dateInfo = "Initié le ${DateFormat('dd/MM/yyyy').format(created)}";
          price = (data['agreedPrice'] ?? 0).toDouble();
          clientId = data['buyerId'];
        }

        return UnifiedHistoryItem(
          bookingId: doc.id,
          vehicleId: vehicleId,
          type: type,
          status: data['status'] ?? 'En attente',
          vehicleName: "${vData['brand']} ${vData['modelName']}",
          imageUrl: (vData['images'] != null && vData['images'].isNotEmpty)
              ? vData['images'][0]
              : '',
          dateInfo: dateInfo,
          totalPrice: price,
          originalModel: data, // Contient toutes les infos de la réservation
          ownerId: data['ownerId'],
          clientId: clientId,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
          isMyListing: isMyListing,
        );
      }

      for (var doc in rentClientSnap.docs) {
        final item = await buildItem(doc, "Location", false);
        if (item != null) tempClient.add(item);
      }
      for (var doc in saleClientSnap.docs) {
        final item = await buildItem(doc, "Vente", false);
        if (item != null) tempClient.add(item);
      }
      for (var doc in rentOwnerSnap.docs) {
        final item = await buildItem(doc, "Location", true);
        if (item != null) tempOwner.add(item);
      }
      for (var doc in saleOwnerSnap.docs) {
        final item = await buildItem(doc, "Vente", true);
        if (item != null) tempOwner.add(item);
      }

      // Tri du plus récent au plus ancien
      tempClient.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      tempOwner.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _clientHistory = tempClient;
      _ownerHistory = tempOwner;
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'historique : $e");
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus({
    required UnifiedHistoryItem item, // On passe l'objet complet
    required String newStatus,
    required bool makeVehicleAvailable,
  }) async {
    try {
      String collectionName = item.type == "Location"
          ? 'rental_bookings'
          : 'sale_bookings';

      // 1. Préparer les champs à mettre à jour dans le dossier
      Map<String, dynamic> updates = {'status': newStatus};

      if (item.type == 'Location') {
        if (newStatus == 'Confirmé') updates['checkInValidated'] = true;
        if (newStatus == 'Fonds Validés') updates['fundsReceived'] = true;
        if (newStatus == 'Véhicule Rendu') updates['checkOutValidated'] = true;
        if (newStatus == 'Terminé') updates['depositRefunded'] = true;
      } else {
        // Vente
        if (newStatus == 'Fonds Validés') updates['fundsReceived'] = true;
        if (newStatus == 'Terminé') {
          updates['vehicleReceived'] = true;
          updates['ownershipTransferred'] = true;
        }
      }

      // 2. Mettre à jour le dossier de transaction
      await _firestore
          .collection(collectionName)
          .doc(item.bookingId)
          .update(updates);

      // 3. Libérer le véhicule (Si location annulée ou terminée)
      if (makeVehicleAvailable) {
        await _firestore.collection('vehicles').doc(item.vehicleId).update({
          'isAvailable': true,
        });
      }

      // 4. MAGIE : TRANSFERT DE PROPRIÉTÉ SI VENTE TERMINÉE !
      if (item.type == 'Vente' && newStatus == 'Terminé') {
        await _firestore.collection('vehicles').doc(item.vehicleId).update({
          'ownerId': item.clientId, // L'acheteur devient le nouveau Boss !
          'isForSale': false, // N'est plus à vendre
          'isForRent': false, // On bloque la loc par précaution
          'isAvailable':
              false, // En attente que le nouveau proprio le configure
          'validationStatus':
              'En attente', // L'admin devra valider sa nouvelle configuration
        });
      }

      // 5. Rafraîchir l'historique localement
      await fetchUserHistory();
    } catch (e) {
      debugPrint("Erreur updateBookingStatus: $e");
      throw Exception("Erreur lors de la mise à jour.");
    }
  }
}
