import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kamer_drive_final/features/notifications/providers/notification_provider.dart';
import 'package:kamer_drive_final/models/notification_model.dart';
import 'package:provider/provider.dart';
import '../../../models/rental_booking_model.dart';
import '../../../models/sale_booking_model.dart';
import '../../../models/unified_history_item_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // --- ÉTATS DE L'HISTORIQUE ---
  List<UnifiedHistoryItem> _clientHistory = [];
  List<UnifiedHistoryItem> get clientHistory => _clientHistory;

  List<UnifiedHistoryItem> _ownerHistory = [];
  List<UnifiedHistoryItem> get ownerHistory => _ownerHistory;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;
  // --- Helper: Mettre le véhicule en Indisponible ---
  Future<void> _setVehicleUnavailable(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'isAvailable': false,
      });
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la disponibilité: $e");
    }
  }

  // --- 1. CRÉER UNE RÉSERVATION (LOCATION) ---
  Future<void> createRentalBooking(
    RentalBookingModel booking,
    BuildContext context,
  ) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception("Utilisateur non connecté.");
      }

      // 1. Enregistrer la réservation
      await _firestore
          .collection('rental_bookings')
          .doc(booking.id)
          .set(booking.toJson());

      // 2. Mettre le véhicule en indisponible
      await _setVehicleUnavailable(booking.vehicleId);

      // 3. ENVOYER LA NOTIFICATION AU PROPRIÉTAIRE
      if (context.mounted) {
        await Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).sendNotification(
          targetUserId: booking.ownerId,
          title: "Nouvelle demande de location ! 🚗",
          message:
              "Un client souhaite louer votre véhicule du ${DateFormat('dd/MM/yyyy').format(booking.startDate)} au ${DateFormat('dd/MM/yyyy').format(booking.endDate)}.",
          type: NotificationType.info,
          route: '/history', // Redirige le propriétaire vers son historique
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur createRentalBooking: $e");
      throw Exception("Impossible de créer la réservation.");
    }
  }

  // --- 2. CRÉER UNE OFFRE D'ACHAT (VENTE) ---
  // NOUVEAU : Ajout de BuildContext context
  Future<void> createSaleBooking(
    SaleBookingModel booking,
    BuildContext context,
  ) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception("Utilisateur non connecté.");
      }

      // 1. Enregistrer l'offre
      await _firestore
          .collection('sale_bookings')
          .doc(booking.id)
          .set(booking.toJson());

      // 2. Mettre le véhicule en indisponible
      await _setVehicleUnavailable(booking.vehicleId);

      // 3. ENVOYER LA NOTIFICATION AU PROPRIÉTAIRE
      if (context.mounted) {
        await Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).sendNotification(
          targetUserId: booking.ownerId,
          title: "Nouvelle offre d'achat ! 💰",
          message:
              "Un client a fait une offre d'achat de ${booking.agreedPrice.toInt()} FCFA pour votre véhicule.",
          type: NotificationType.success, // En vert pour une vente !
          route: '/history',
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur createSaleBooking: $e");
      throw Exception("Impossible d'envoyer l'offre d'achat.");
    }
  }

  Future<void> fetchUserHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      // A. Requêtes Firestore (Client et Propriétaire)
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

      // B. Traitement et récupération des détails des véhicules
      List<UnifiedHistoryItem> tempClient = [];
      List<UnifiedHistoryItem> tempOwner = [];

      // Fonction Helper interne pour mapper les données
      Future<UnifiedHistoryItem?> buildItem(
        DocumentSnapshot doc,
        String type,
        bool isMyListing, // <-- This parameter determines if it's an owner view
      ) async {
        final data = doc.data() as Map<String, dynamic>;
        final vehicleId = data['vehicleId'];

        // On va chercher le nom et la photo de la voiture
        final vehicleDoc = await _firestore
            .collection('vehicles')
            .doc(vehicleId)
            .get();
        if (!vehicleDoc.exists) return null;
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
          dateInfo = "Initié le ${DateFormat('dd/MM').format(created)}";
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
          originalModel: data,
          ownerId: data['ownerId'],
          clientId: clientId,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
          isMyListing: isMyListing, // <-- Pass the parameter here!
        );
      }

      // C. Remplissage des listes
      // --- Vues Client (isMyListing = false) ---
      for (var doc in rentClientSnap.docs) {
        final item = await buildItem(doc, "Location", false);
        if (item != null) tempClient.add(item);
      }
      for (var doc in saleClientSnap.docs) {
        final item = await buildItem(doc, "Vente", false);
        if (item != null) tempClient.add(item);
      }

      // --- Vues Propriétaire (isMyListing = true) ---
      for (var doc in rentOwnerSnap.docs) {
        final item = await buildItem(doc, "Location", true);
        if (item != null) tempOwner.add(item);
      }
      for (var doc in saleOwnerSnap.docs) {
        final item = await buildItem(doc, "Vente", true);
        if (item != null) tempOwner.add(item);
      }

      // D. Tri par date (du plus récent au plus ancien)
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

  // --- 4. METTRE À JOUR UN STATUT (ET LIBÉRER LE VÉHICULE SI BESOIN) ---
  Future<void> updateBookingStatus({
    required String collectionName, // 'rental_bookings' ou 'sale_bookings'
    required String bookingId,
    required String newStatus,
    required String vehicleId,
    required bool
    makeVehicleAvailable, // Mettre à true si on annule/refuse/termine
  }) async {
    try {
      // 1. Met à jour la réservation
      await _firestore.collection(collectionName).doc(bookingId).update({
        'status': newStatus,
      });

      // 2. Si la transaction est finie/annulée, on remet la voiture sur le marché
      if (makeVehicleAvailable) {
        await _firestore.collection('vehicles').doc(vehicleId).update({
          'isAvailable': true,
        });
      }

      // 3. Rafraîchit l'historique en local
      await fetchUserHistory();
    } catch (e) {
      debugPrint("Erreur updateBookingStatus: $e");
      throw Exception("Erreur lors de la mise à jour.");
    }
  }
}
