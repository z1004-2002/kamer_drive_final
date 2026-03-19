import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/vehicle_details_modal.dart';
import '../../../models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  // --- FONCTION DE RAFRAÎCHISSEMENT ---
  Future<void> _refreshMyVehicles() async {
    // Simule un court temps de chargement pour rassurer l'utilisateur
    // (Le StreamBuilder se met déjà à jour tout seul en arrière-plan)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final vehicleProvider = Provider.of<VehicleProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            left: -size.width * 0.3,
            bottom: size.height * 0.4,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            right: -size.width * 0.4,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, dPrimaryColor],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Mes Véhicules",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<List<VehicleModel>>(
                  stream: vehicleProvider.getMyVehicles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Erreur de chargement."));
                    }

                    // CAS 1 : LISTE VIDE AVEC PULL-TO-REFRESH
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshMyVehicles,
                        color: kPrimaryColor,
                        backgroundColor: Colors.white,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height:
                                size.height * 0.6, // Pour centrer le message
                            child: _buildEmptyState(context),
                          ),
                        ),
                      );
                    }

                    // CAS 2 : LISTE DE VÉHICULES AVEC PULL-TO-REFRESH
                    final vehicles = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refreshMyVehicles,
                      color: kPrimaryColor,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 100,
                          left: 20,
                          right: 20,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) =>
                            _buildManagementCard(vehicles[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_vehicle'),
        backgroundColor: kPrimaryColor,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Ajouter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildManagementCard(VehicleModel vehicle) {
    Color statusColor;
    IconData statusIcon;
    switch (vehicle.validationStatus) {
      case "Validé":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Rejeté":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return GestureDetector(
      onTap: () => showVehicleDetailsModal(
        context,
        vehicle,
        isRentContext: vehicle.isForRent, // Par défaut sur loc si dispo
        isOwnerView: true,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 130, // Légèrement plus haut pour les deux prix
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 110,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: lPrimaryColor,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: vehicle.images.isNotEmpty
                    ? Image.network(vehicle.images.first, fit: BoxFit.cover)
                    : const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: kPrimaryColor,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${vehicle.brand} ${vehicle.modelName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),

                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        if (vehicle.isForRent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              "Location",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (vehicle.isForSale)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              "Vente",
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (!vehicle.isForRent && !vehicle.isForSale)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              "Privé",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- AFFICHAGE DES PRIX OU STATUT PRIVÉ ---
                    if (vehicle.isForRent && vehicle.rentPricePerDay != null)
                      Text(
                        "${vehicle.rentPricePerDay!.toInt()} FCFA /jour",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                          fontSize: 13,
                        ),
                      ),
                    if (vehicle.isForSale && vehicle.salePrice != null)
                      Text(
                        "${vehicle.salePrice!.toInt()} FCFA (Total)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    // NOUVEAU : Message si privé
                    if (!vehicle.isForRent && !vehicle.isForSale)
                      Text(
                        "Non en service (privé)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          vehicle.validationStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Menu d'actions (Modifier/Supprimer)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Modifier")),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text("Supprimer", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.car_rental, size: 60, color: Colors.grey.shade300),
        const SizedBox(height: 15),
        const Text(
          "Vous n'avez pas encore enregistré de véhicule.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
