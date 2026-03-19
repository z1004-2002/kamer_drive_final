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
  // On déclare l'index ici pour qu'il soit accessible par le StatefulBuilder
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
          // --- LOGIQUE DE COULEUR ---
          Color themeColor = isRentContext
              ? kPrimaryColor
              : Colors.orange.shade700;
          Color lightThemeColor = isRentContext
              ? lPrimaryColor
              : Colors.orange.shade50;

          // On gère les couleurs spécifiques si la voiture est privée (grisée)
          bool isPrivate = !vehicle.isForRent && !vehicle.isForSale;
          if (isPrivate) {
            themeColor = Colors.grey.shade700;
            lightThemeColor = Colors.grey.shade200;
          }

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

                        // 1. CAROUSEL D'IMAGES
                        _buildCarousel(
                          vehicle,
                          currentImageIndex,
                          // NOUVEAU : On passe un callback qui met à jour la vraie variable
                          (index) {
                            setModalState(() {
                              currentImageIndex = index as int;
                            });
                          },
                          themeColor,
                          lightThemeColor,
                        ),

                        // 2. CONTENU TEXTUEL
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
                              if (vehicle.isForRent &&
                                  vehicle.securityDeposit != null &&
                                  vehicle.securityDeposit! > 0) ...[
                                const SizedBox(height: 25),
                                const Text(
                                  "Conditions de location",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        color: Colors.orange.shade700,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Caution (Remboursable)",
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${vehicle.securityDeposit!.toInt()} FCFA",
                                              style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

                // --- 3. BARRE FIXE DYNAMIQUE ---
                _buildBottomActionArea(
                  context,
                  vehicle,
                  isRentContext,
                  isOwnerView,
                  isMyVehicle,
                  themeColor,
                  isPrivate,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// --- SOUS-WIDGETS POUR LA CLARTÉ ---

Widget _buildCarousel(
  VehicleModel vehicle,
  int currentIndex,
  ValueChanged<int> onPageChanged, // NOUVEAU : On utilise un Callback ici
  Color theme,
  Color lightTheme,
) {
  return SizedBox(
    height: 250,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          physics: const BouncingScrollPhysics(),
          onPageChanged:
              onPageChanged, // NOUVEAU : On appelle le callback directement
          itemCount: vehicle.images.isNotEmpty ? vehicle.images.length : 1,
          itemBuilder: (context, index) {
            if (vehicle.images.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: lightTheme,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.directions_car, size: 80, color: theme),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: vehicle.images[index].startsWith('http')
                    ? Image.network(
                        vehicle.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : Image.asset(
                        vehicle.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  vehicle.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    // L'animation fonctionne car currentIndex est maintenant parfaitement à jour !
                    width: currentIndex == index ? 18 : 6,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

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

Widget _buildBottomActionArea(
  BuildContext context,
  VehicleModel vehicle,
  bool isRentContext,
  bool isOwnerView,
  bool isMyVehicle,
  Color themeColor,
  bool isPrivate,
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
          // --- ZONE DES PRIX ---
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cas 1 : Le véhicule est privé (ni location, ni vente)
                if (isPrivate)
                  Text(
                    "Non en service (privé)",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  )
                // Cas 2 : Le véhicule a des prix définis
                else ...[
                  if (isOwnerView || (isRentContext && vehicle.isForRent))
                    Text(
                      "${vehicle.rentPricePerDay?.toInt()} FCFA/j (Loc.)",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  if (isOwnerView || (!isRentContext && vehicle.isForSale))
                    Text(
                      "${vehicle.salePrice?.toInt()} FCFA (Vente)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                ],
              ],
            ),
          ),

          // --- BOUTON D'ACTION ---
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isMyVehicle) {
                // TODO: Naviguer vers l'écran d'édition
              } else if (!isPrivate) {
                // TODO: Logique de réservation ou de contact si ce n'est pas privé
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isMyVehicle ? Colors.black87 : themeColor,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              isMyVehicle
                  ? "Modifier"
                  : (isRentContext ? "Continuer" : "Contacter"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
