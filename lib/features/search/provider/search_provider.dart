import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/vehicle_model.dart';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<VehicleModel> _allVehicles = []; // Tous les véhicules de la BD
  List<VehicleModel> _filteredVehicles = []; // Les 15 résultats affichés

  List<VehicleModel> get filteredVehicles => _filteredVehicles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Télécharger les données une seule fois
  Future<void> fetchAllVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? currentUserId = _auth.currentUser?.uid;

      // On récupère les véhicules validés (Triés du plus récent au plus ancien)
      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('validationStatus', isEqualTo: 'Validé')
          .where('isAvailable', isEqualTo: true)
          // .orderBy('createdAt', descending: true)
          .get();

      _allVehicles = querySnapshot.docs
          .map((doc) => VehicleModel.fromJson(doc.data()))
          .where((v) => v.ownerId != currentUserId) // On exclut tes véhicules !
          .toList();

      // Au début, on affiche les 15 plus récents sans filtre
      _filteredVehicles = _allVehicles.take(15).toList();
    } catch (e) {
      debugPrint("Erreur SearchProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Appliquer les filtres en local (Instantané)
  void applyFilters({
    required String searchQuery,
    required String transactionType,
    required String brand,
    required String gearbox,
    required String fuelType,
    required double minSeats,
    required bool requireAC,
    required RangeValues rentPriceRange,
    required RangeValues salePriceRange,
  }) {
    _filteredVehicles = _allVehicles
        .where((v) {
          // 1. Recherche textuelle (Marque + Modèle)
          if (searchQuery.isNotEmpty) {
            String fullName = "${v.brand} ${v.modelName}".toLowerCase();
            if (!fullName.contains(searchQuery.toLowerCase())) return false;
          }

          // 2. Filtres Basiques
          if (!v.isAvailable) return false;
          if (transactionType == 'rent' && !v.isForRent) return false;
          if (transactionType == 'sale' && !v.isForSale) return false;
          if (brand != 'Toutes' && v.brand != brand) return false;
          if (gearbox != 'Toutes' && v.gearbox != gearbox) return false;
          if (fuelType != 'Tous' && v.fuelType != fuelType) return false;
          if (v.seats < minSeats) return false;
          if (requireAC && !v.hasAC) return false;

          // 3. Filtres de Prix
          if (transactionType == 'rent' && v.rentPricePerDay != null) {
            if (v.rentPricePerDay! < rentPriceRange.start ||
                v.rentPricePerDay! > rentPriceRange.end)
              return false;
          }
          if (transactionType == 'sale' && v.salePrice != null) {
            if (v.salePrice! < salePriceRange.start ||
                v.salePrice! > salePriceRange.end)
              return false;
          }

          return true;
        })
        .take(30) // MAX 30 RÉSULTATS !
        .toList();

    notifyListeners();
  }
}
