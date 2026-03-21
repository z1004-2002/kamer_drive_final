import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NOUVEAU: Import de l'Auth
import '../../../models/vehicle_model.dart';

class HomeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // NOUVEAU: Instance Auth

  // Listes pour stocker les données
  List<VehicleModel> _recentRentalVehicles = [];
  List<VehicleModel> get recentRentalVehicles => _recentRentalVehicles;

  List<VehicleModel> _recentSaleVehicles = [];
  List<VehicleModel> get recentSaleVehicles => _recentSaleVehicles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fonction principale pour récupérer l'accueil
  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // NOUVEAU : On récupère l'ID de l'utilisateur actuellement connecté
      final String? currentUserId = _auth.currentUser?.uid;

      // 1. Récupérer les locations récentes (uniquement celles validées par l'admin)
      final rentQuery = await _firestore
          .collection('vehicles')
          .where('validationStatus', isEqualTo: 'Validé')
          .where('isForRent', isEqualTo: true)
          // .orderBy('createdAt', descending: true)
          .limit(
            15,
          ) // On en demande un peu plus (15) au cas où les premiers seraient les tiens
          .get();

      _recentRentalVehicles = rentQuery.docs
          // NOUVEAU : On exclut les véhicules dont tu es le propriétaire
          .where((doc) => doc.data()['ownerId'] != currentUserId)
          .map((doc) => VehicleModel.fromJson(doc.data()))
          .take(5)
          .toList();

      // 2. Récupérer les ventes récentes (uniquement celles validées)
      final saleQuery = await _firestore
          .collection('vehicles')
          .where('validationStatus', isEqualTo: 'Validé')
          .where('isForSale', isEqualTo: true)
          // .orderBy('createdAt', descending: true)
          .limit(15)
          .get();

      _recentSaleVehicles = saleQuery.docs
          // NOUVEAU : On exclut tes propres véhicules
          .where((doc) => doc.data()['ownerId'] != currentUserId)
          .map((doc) => VehicleModel.fromJson(doc.data()))
          .take(5) // On garde les 5 premiers
          .toList();
    } catch (e) {
      debugPrint(
        "Erreur lors de la récupération des véhicules de l'accueil: $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners(); // Met à jour l'interface avec les nouvelles listes
    }
  }
}
