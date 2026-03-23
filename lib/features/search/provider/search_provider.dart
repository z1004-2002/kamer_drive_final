import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/vehicle_model.dart';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _filteredVehicles = [];

  List<VehicleModel> get filteredVehicles => _filteredVehicles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- DYNAMIC FILTER DATA ---
  List<String> availableBrands = ["Toutes"];
  List<String> availableCities = ["Toutes"];

  double minRentPrice = 10000;
  double maxRentPrice = 200000;
  double minSalePrice = 1000000;
  double maxSalePrice = 50000000;

  // 1. Fetch data and compute dynamic filters
  Future<void> fetchAllVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? currentUserId = _auth.currentUser?.uid;

      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('validationStatus', isEqualTo: 'Validé')
          .where('isAvailable', isEqualTo: true)
          .get();

      // Ensure we have data before processing
      if (querySnapshot.docs.isEmpty) {
        _allVehicles = [];
        _filteredVehicles = [];
        return;
      }

      // Filter out user's own vehicles
      _allVehicles = querySnapshot.docs
          .map((doc) => VehicleModel.fromJson(doc.data()))
          .where((v) => v.ownerId != currentUserId)
          .toList();

      // --- COMPUTE DYNAMIC FILTERS ---
      Set<String> brandsSet = {"Toutes"};
      Set<String> citiesSet = {"Toutes"};

      double lowestRent = double.infinity;
      double highestRent = 0;
      double lowestSale = double.infinity;
      double highestSale = 0;

      for (var vehicle in _allVehicles) {
        // 1. Brands & Cities
        if (vehicle.brand.isNotEmpty) brandsSet.add(vehicle.brand);
        if (vehicle.city.isNotEmpty) citiesSet.add(vehicle.city);

        // 2. Rent Prices
        if (vehicle.isForRent && vehicle.rentPricePerDay != null) {
          if (vehicle.rentPricePerDay! < lowestRent)
            lowestRent = vehicle.rentPricePerDay!;
          if (vehicle.rentPricePerDay! > highestRent)
            highestRent = vehicle.rentPricePerDay!;
        }

        // 3. Sale Prices
        if (vehicle.isForSale && vehicle.salePrice != null) {
          if (vehicle.salePrice! < lowestSale) lowestSale = vehicle.salePrice!;
          if (vehicle.salePrice! > highestSale)
            highestSale = vehicle.salePrice!;
        }
      }

      // Sort strings alphabetically
      availableBrands = brandsSet.toList()
        ..sort((a, b) => a == "Toutes" ? -1 : a.compareTo(b));
      availableCities = citiesSet.toList()
        ..sort((a, b) => a == "Toutes" ? -1 : a.compareTo(b));

      // Set Prices (Add fallbacks if no rent/sale vehicles exist)
      minRentPrice = lowestRent == double.infinity ? 5000 : lowestRent;
      maxRentPrice = highestRent == 0 ? 200000 : highestRent;

      minSalePrice = lowestSale == double.infinity ? 500000 : lowestSale;
      maxSalePrice = highestSale == 0 ? 50000000 : highestSale;

      // Initialize filtered list
      _filteredVehicles = _allVehicles.take(15).toList();
    } catch (e) {
      debugPrint("Erreur SearchProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Apply local filters
  void applyFilters({
    required String searchQuery,
    required String transactionType,
    required String brand,
    required String city, // NOUVEAU
    required String gearbox,
    required String fuelType,
    required double minSeats,
    required bool requireAC,
    required RangeValues rentPriceRange,
    required RangeValues salePriceRange,
  }) {
    _filteredVehicles = _allVehicles
        .where((v) {
          // 1. Text Search
          if (searchQuery.isNotEmpty) {
            String fullName = "${v.brand} ${v.modelName}".toLowerCase();
            if (!fullName.contains(searchQuery.toLowerCase())) return false;
          }

          // 2. Basic Filters
          if (transactionType == 'rent' && !v.isForRent) return false;
          if (transactionType == 'sale' && !v.isForSale) return false;

          if (brand != 'Toutes' && v.brand != brand) return false;
          if (city != 'Toutes' && v.city != city) return false; // NOUVEAU

          if (gearbox != 'Toutes' && v.gearbox != gearbox) return false;
          if (fuelType != 'Tous' && v.fuelType != fuelType) return false;
          if (v.seats < minSeats) return false;
          if (requireAC && !v.hasAC) return false;

          // 3. Price Filters
          if (transactionType == 'rent' || transactionType == 'all') {
            // Only strictly filter out if it IS for rent and out of range
            if (v.isForRent && v.rentPricePerDay != null) {
              if (v.rentPricePerDay! < rentPriceRange.start ||
                  v.rentPricePerDay! > rentPriceRange.end) {
                // If it's "all" and also for sale (and sale is in range), keep it. Otherwise, drop.
                if (transactionType == 'rent') return false;
                if (transactionType == 'all' && !v.isForSale) return false;
              }
            }
          }

          if (transactionType == 'sale' || transactionType == 'all') {
            if (v.isForSale && v.salePrice != null) {
              if (v.salePrice! < salePriceRange.start ||
                  v.salePrice! > salePriceRange.end) {
                if (transactionType == 'sale') return false;
                if (transactionType == 'all' && !v.isForRent) return false;
              }
            }
          }

          return true;
        })
        .take(30)
        .toList();

    notifyListeners();
  }
}
