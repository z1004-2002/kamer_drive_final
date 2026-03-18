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
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      );
                    if (snapshot.hasError)
                      return const Center(child: Text("Erreur de chargement."));
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return _buildEmptyState(context);

                    final vehicles = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 100,
                        left: 20,
                        right: 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) =>
                          _buildManagementCard(vehicles[index]),
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
    // 1. Couleurs de statut (En attente, Validé...)
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

    // 2. NOUVELLE LOGIQUE : Type et Prix dynamiques
    String typeLabel;
    String priceLabel;
    Color typeColor;
    Color typeBgColor;

    if (vehicle.isForRent) {
      typeLabel = "Location";
      priceLabel = "${vehicle.rentPricePerDay?.toInt() ?? 0} FCFA/j";
      typeColor = kPrimaryColor;
      typeBgColor = kPrimaryColor.withOpacity(0.1);
    } else if (vehicle.isForSale) {
      typeLabel = "Vente";
      priceLabel = "${vehicle.salePrice?.toInt() ?? 0} FCFA";
      typeColor = Colors.orange.shade700;
      typeBgColor = Colors.orange.withOpacity(0.1);
    } else {
      // Cas de repli : Usage privé / Non spécifié
      typeLabel = "Privé";
      priceLabel = "-";
      typeColor = Colors.grey.shade700;
      typeBgColor = Colors.grey.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: () => showVehicleDetailsModal(context, vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 120,
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
                    ? Image.network(
                        vehicle.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.directions_car,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      )
                    : const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: kPrimaryColor,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${vehicle.brand} ${vehicle.modelName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Année: ${vehicle.year}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Tag coloré dynamiquement (Vert, Orange, ou Gris)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeBgColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            priceLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onSelected: (value) {
                /* Action modifier / supprimer */
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 10),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Text("Vous n'avez pas encore enregistré de véhicule."),
    );
  }
}
