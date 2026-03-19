import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import '../../../models/vehicle_model.dart';

void showVehicleDetailsModal(
  BuildContext context,
  VehicleModel vehicle, {
  bool isRentContext = true,
  bool isOwnerView = false,
}) {
  // On déclare l'index ici pour qu'il soit accessible
  int currentImageIndex = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final bool isMyVehicle = vehicle.ownerId == currentUserId;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          Color themeColor = isRentContext
              ? kPrimaryColor
              : Colors.orange.shade700;
          Color lightThemeColor = isRentContext
              ? lPrimaryColor
              : Colors.orange.shade50;

          double rating = vehicle.reviews.isEmpty
              ? 4.8
              : vehicle.reviews.map((e) => e.rating).reduce((a, b) => a + b) /
                    vehicle.reviews.length;

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // --- 1. CAROUSEL D'IMAGES ---
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                onPageChanged: (index) {
                                  // CRUCIAL : Utiliser setModalState pour rafraîchir la modal
                                  setModalState(() {
                                    currentImageIndex = index;
                                  });
                                },
                                itemCount: vehicle.images.isNotEmpty
                                    ? vehicle.images.length
                                    : 1,
                                itemBuilder: (context, index) {
                                  if (vehicle.images.isEmpty) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightThemeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 80,
                                        color: themeColor,
                                      ),
                                    );
                                  }
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        vehicle.images[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // --- LES DOTS (INDICATEURS) ---
                              if (vehicle.images.length > 1)
                                Positioned(
                                  bottom: 15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        vehicle.images.length,
                                        (index) => AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          height: 6,
                                          width: currentImageIndex == index
                                              ? 18
                                              : 6,
                                          decoration: BoxDecoration(
                                            color: currentImageIndex == index
                                                ? Colors.white
                                                : Colors.white54,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // --- 2. CONTENU ---
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(vehicle, rating),
                              const SizedBox(height: 8),
                              _buildLocationAndYear(vehicle),
                              const SizedBox(height: 25),
                              const Text(
                                "Caractéristiques",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildSpecs(vehicle, themeColor, lightThemeColor),
                              const SizedBox(height: 25),
                              const Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                vehicle.description,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 3. BARRE DE PRIX ET ACTION ---
                _buildBottomActionArea(
                  context,
                  vehicle,
                  isRentContext,
                  isOwnerView,
                  isMyVehicle,
                  themeColor,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Les fonctions helpers restent identiques, assure-toi qu'elles sont bien définies en dessous :

Widget _buildHeader(VehicleModel vehicle, double rating) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          "${vehicle.brand} ${vehicle.modelName}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildLocationAndYear(VehicleModel vehicle) {
  return Row(
    children: [
      const Icon(Icons.location_on, color: Colors.grey, size: 16),
      Text(
        " ${vehicle.city}",
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      const SizedBox(width: 15),
      const Icon(Icons.calendar_month, color: Colors.grey, size: 16),
      Text(
        " ${vehicle.year}",
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    ],
  );
}

Widget _buildSpecs(VehicleModel vehicle, Color theme, Color lightTheme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildSpecIcon(
        Icons.airline_seat_recline_normal,
        "${vehicle.seats} Pl.",
        theme,
        lightTheme,
      ),
      _buildSpecIcon(Icons.settings, vehicle.gearbox, theme, lightTheme),
      _buildSpecIcon(
        Icons.local_gas_station,
        vehicle.fuelType,
        theme,
        lightTheme,
      ),
      _buildSpecIcon(
        Icons.ac_unit,
        vehicle.hasAC ? "Clim" : "Non",
        theme,
        lightTheme,
      ),
    ],
  );
}

Widget _buildBottomActionArea(
  BuildContext context,
  VehicleModel vehicle,
  bool isRent,
  bool isOwner,
  bool isMyVehicle,
  Color theme,
) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwner || (isRent && vehicle.isForRent))
                  Text(
                    "${vehicle.rentPricePerDay?.toInt()} FCFA/j (Loc.)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                if (isOwner || (!isRent && vehicle.isForSale))
                  Text(
                    "${vehicle.salePrice?.toInt()} FCFA (Vente)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isMyVehicle ? Colors.black87 : theme,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              isMyVehicle ? "Modifier" : (isRent ? "Continuer" : "Contacter"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSpecIcon(
  IconData icon,
  String label,
  Color iconColor,
  Color bgColor,
) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
