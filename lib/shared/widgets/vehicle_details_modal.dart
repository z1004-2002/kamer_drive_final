import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NOUVEAU: Requis pour aller chercher l'utilisateur
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import 'package:kamer_drive_final/features/my_listings/providers/vehicle_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/vehicle_model.dart';

void showVehicleDetailsModal(
  BuildContext context,
  VehicleModel vehicle, {
  bool isRentContext = true,
  bool isOwnerView = false,
}) {
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

                              if (vehicle.isForRent) ...[
                                const SizedBox(height: 25),
                                const Text(
                                  "Tarifs & Conditions de location",
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
                                  child: Column(
                                    children: [
                                      // Prix Standard
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Sans chauffeur :",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${vehicle.rentPricePerDay?.toInt()} FCFA/j",
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),

                                      // Prix avec Chauffeur
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Avec chauffeur :",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          vehicle.withDriverOption == true &&
                                                  vehicle.rentPriceWithDriver !=
                                                      null
                                              ? Text(
                                                  "${vehicle.rentPriceWithDriver?.toInt()} FCFA/j",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.orange.shade800,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : const Text(
                                                  "Non disponible",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                        ],
                                      ),
                                      const Divider(height: 20),

                                      // Caution
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.shield_outlined,
                                                color: Colors.orange.shade700,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Caution remboursable :",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            (vehicle.securityDeposit ?? 0) > 0
                                                ? "${vehicle.securityDeposit!.toInt()} FCFA"
                                                : "Aucune",
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
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

                              if (!isMyVehicle) ...[
                                const SizedBox(height: 25),
                                const Text(
                                  "Propriétaire",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildOwnerInfo(vehicle.ownerId, themeColor),
                              ],

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

// --- SOUS-WIDGET : PROPRIÉTAIRE (FETCH FIRESTORE) ---
Widget _buildOwnerInfo(String ownerId, Color themeColor) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
    builder: (context, snapshot) {
      // 1. État de chargement
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: themeColor),
          ),
        );
      }

      // 2. Utilisateur introuvable
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Text(
            "Informations du propriétaire indisponibles.",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      // 3. Affichage des données
      final data = snapshot.data!.data() as Map<String, dynamic>;
      final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
          .trim();
      final phone = data['phone'] ?? 'Non renseigné';
      final email = data['email'] ?? 'Non renseigné';
      final avatarUrl = data['avatarUrl'] ?? '';

      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: themeColor.withOpacity(0.1),
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person, color: themeColor, size: 30)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.email,
                          size: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- SOUS-WIDGETS POUR LA CLARTÉ ---

Widget _buildCarousel(
  VehicleModel vehicle,
  int currentIndex,
  ValueChanged<int> onPageChanged,
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
          onPageChanged: onPageChanged,
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
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPrivate)
                  Text(
                    "Non en service (privé)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  )
                else ...[
                  // On affiche le prix de location SI c'est à louer
                  if (vehicle.isForRent)
                    Text(
                      vehicle.withDriverOption == true
                          ? "Dès ${vehicle.rentPricePerDay?.toInt()} FCFA/j"
                          : "${vehicle.rentPricePerDay?.toInt()} FCFA/j",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // On affiche le prix de vente SI c'est à vendre
                  if (vehicle.isForSale)
                    Text(
                      "${vehicle.salePrice?.toInt()} FCFA (Vente)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // --- BOUTON(S) D'ACTION ---
          Expanded(
            flex: 6,
            child: isMyVehicle
                // SI C'EST MON VÉHICULE -> Bouton Modifier
                ? Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // --- DEMANDE DE CONFIRMATION AVANT SUPPRESSION ---
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Supprimer l'annonce",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  "Êtes-vous sûr de vouloir supprimer définitivement ce véhicule ? Cette action est irréversible et retirera le véhicule de la plateforme.",
                                  style: TextStyle(
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text(
                                      "Annuler",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(
                                        ctx,
                                      ); // 1. Ferme la boîte de confirmation
                                      Navigator.pop(
                                        context,
                                      ); // 2. Ferme la modale du véhicule

                                      // 3. Exécute la suppression dans Firebase
                                      try {
                                        await context
                                            .read<VehicleProvider>()
                                            .deleteVehicle(vehicle.id);
                                        if (context.mounted) {
                                          SnackbarUtils.showSuccess(
                                            context,
                                            "Le véhicule a été supprimé.",
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          // e.toString() va afficher le fameux "Exception: Impossible : Ce véhicule a des transactions en cours."
                                          String errorMsg = e
                                              .toString()
                                              .replaceAll("Exception: ", "");
                                          SnackbarUtils.showError(
                                            context,
                                            errorMsg,
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Oui, supprimer",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade700,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 2. BOUTON MODIFIER
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Ferme la modale
                            context.push(
                              '/edit_vehicle',
                              extra: vehicle,
                            ); // Va à la page d'édition
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Modifier",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : isPrivate
                // SI C'EST PRIVÉ -> Rien
                ? const SizedBox.shrink()
                // SI C'EST POUR LES CLIENTS -> 1 ou 2 boutons
                : Row(
                    children: [
                      if (vehicle.isForRent)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/rental_booking', extra: vehicle),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Réserver",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      if (vehicle.isForRent && vehicle.isForSale)
                        const SizedBox(
                          width: 8,
                        ), // Espace entre les deux boutons
                      if (vehicle.isForSale)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/sale_booking', extra: vehicle),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Acheter",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}
