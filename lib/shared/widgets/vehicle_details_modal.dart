import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import '../../../models/vehicle_model.dart';

void showVehicleDetailsModal(BuildContext context, VehicleModel vehicle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      int currentImageIndex = 0;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // --- NOUVELLE LOGIQUE DE PRIX ---
          String displayPrice = "Non défini";
          String priceLabel = "Prix";

          if (vehicle.isForRent && vehicle.rentPricePerDay != null) {
            displayPrice = "${vehicle.rentPricePerDay!.toInt()} FCFA";
            priceLabel = "Prix par jour";
          } else if (vehicle.isForSale && vehicle.salePrice != null) {
            displayPrice = "${vehicle.salePrice!.toInt()} FCFA";
            priceLabel = "Prix de vente";
          } else {
            // S'il n'est ni en vente ni en location
            displayPrice = "-";
            priceLabel = "Usage privé";
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
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                onPageChanged: (index) => setModalState(
                                  () => currentImageIndex = index,
                                ),
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
                                        color: lPrimaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.directions_car,
                                        size: 80,
                                        color: kPrimaryColor,
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
                              if (vehicle.images.length > 1)
                                Positioned(
                                  bottom: 15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
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
                                              ? 15
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

                        // 2. INFORMATIONS DE LA VOITURE
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${vehicle.brand} ${vehicle.modelName}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
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
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  Text(
                                    " ${vehicle.city}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  Text(
                                    " ${vehicle.year}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              const Text(
                                "Caractéristiques",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSpecIcon(
                                    Icons.airline_seat_recline_normal,
                                    "${vehicle.seats} Places",
                                  ),
                                  _buildSpecIcon(
                                    Icons.settings,
                                    vehicle.gearbox,
                                  ),
                                  _buildSpecIcon(
                                    Icons.local_gas_station,
                                    vehicle.fuelType,
                                  ),
                                  _buildSpecIcon(
                                    Icons.ac_unit,
                                    vehicle.hasAC ? "Climatisé" : "Sans Clim",
                                  ),
                                ],
                              ),

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

                // --- BOUTON FIXE EN BAS ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              priceLabel,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              displayPrice,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        // Si le véhicule n'est ni à louer ni à vendre, on peut désactiver ou cacher le bouton
                        if (vehicle.isForRent || vehicle.isForSale)
                          ElevatedButton(
                            onPressed: () {
                              /* Action */
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Continuer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildSpecIcon(IconData icon, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lPrimaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: kPrimaryColor, size: 24),
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
