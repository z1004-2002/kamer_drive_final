import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';
import 'package:kamer_drive_final/shared/widgets/vehicle_details_modal.dart';
import 'package:provider/provider.dart';
import '../../../models/vehicle_model.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;

  const HomeScreen({super.key, required this.onNavigateToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- FAUSSES DONNÉES POUR LE MVP (À remplacer par Firestore plus tard) ---
  final List<VehicleModel> _rentalVehicles = [
    VehicleModel(
      id: "1",
      ownerId: "user1",
      brand: "Toyota",
      modelName: "Corolla",
      year: 2021,
      city: "Douala",
      address: "",
      images: [
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
      ],
      description:
          "Superbe Toyota Corolla très économique, parfaite pour vos courses en ville. Entretien à jour.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 35000,
      isForSale: false,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "2",
      ownerId: "user2",
      brand: "Hyundai",
      modelName: "Tucson",
      year: 2022,
      city: "Yaoundé",
      address: "",
      images: [
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
      ],
      description:
          "SUV spacieux et confortable pour vos voyages en famille. Sièges en cuir.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 60000,
      isForSale: false,
      seats: 4,
      gearbox: "Automatique",
      fuelType: "Diesel",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "1",
      ownerId: "user1",
      brand: "Toyota",
      modelName: "Corolla",
      year: 2021,
      city: "Douala",
      address: "",
      images: [
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
      ],
      description:
          "Superbe Toyota Corolla très économique, parfaite pour vos courses en ville. Entretien à jour.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 35000,
      isForSale: false,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
  ];

  final List<VehicleModel> _saleVehicles = [
    VehicleModel(
      id: "3",
      ownerId: "user3",
      brand: "Mercedes-Benz",
      modelName: "C300",
      year: 2019,
      city: "Douala",
      address: "",
      images: [
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
      ],
      description:
          "Véhicule de luxe en parfait état. Moteur V6, toit ouvrant panoramique.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: false,
      isForSale: true,
      salePrice: 15000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "3",
      ownerId: "user3",
      brand: "Mercedes-Benz",
      modelName: "C300",
      year: 2019,
      city: "Douala",
      address: "",
      images: [
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
        "assets/images/cars/car1.jpg",
      ],
      description:
          "Véhicule de luxe en parfait état. Moteur V6, toit ouvrant panoramique.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: false,
      isForSale: true,
      salePrice: 15000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "3",
      ownerId: "user3",
      brand: "Mercedes-Benz",
      modelName: "C300",
      year: 2019,
      city: "Douala",
      address: "",
      images: [
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
        "assets/images/cars/car2.jpg",
      ],
      description:
          "Véhicule de luxe en parfait état. Moteur V6, toit ouvrant panoramique.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: false,
      isForSale: true,
      salePrice: 15000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userName = currentUser?.firstName ?? "Utilisateur";

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // CERCLES DÉCORATIFS
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
          Positioned(
            top: size.height * 0.5,
            child: Opacity(
              opacity: 0.1,
              child: SizedBox(
                width: size.width,
                child: Center(child: Name(size: size.width * 0.15)),
              ),
            ),
          ),

          // CONTENU PRINCIPAL
          Column(
            children: [
              _buildFixedHeader(userName), // Header anti-overflow

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 15, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        "Véhicules en Location",
                        () => widget.onNavigateToSearch(),
                      ),
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: _rentalVehicles.length,
                          itemBuilder: (context, index) =>
                              _buildVehicleCard(_rentalVehicles[index]),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        "Véhicules à Vendre",
                        () => widget.onNavigateToSearch(),
                      ),
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: _saleVehicles.length,
                          itemBuilder: (context, index) =>
                              _buildVehicleCard(_saleVehicles[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HEADER AVEC LA CORRECTION D'OVERFLOW
  Widget _buildFixedHeader(String userName) {
    return SizedBox(
      height: 215,
      child: Stack(
        children: [
          Container(
            height: 190,
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
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bonjour, $userName",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Trouvez votre véhicule idéal",
                            style: TextStyle(
                              color: lPrimaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: widget.onNavigateToSearch,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 5),
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    const Icon(Icons.search, color: kPrimaryColor),
                    const SizedBox(width: 10),
                    Text(
                      "Rechercher une voiture...",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "Voir tout",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // CARTE DE VÉHICULE CLIQUABLE
  Widget _buildVehicleCard(VehicleModel vehicle) {
    String priceDisplay = vehicle.isForRent
        ? "${vehicle.rentPricePerDay?.toInt()} FCFA"
        : "${vehicle.salePrice?.toInt()} FCFA";
    String period = vehicle.isForRent ? "/jour" : "";
    double rating = vehicle.reviews.isEmpty
        ? 4.8
        : 4.8; // Simplifié pour le design

    return GestureDetector(
      onTap: () {
        // --- C'EST ICI QU'ON APPELLE LE MODAL ---
        showVehicleDetailsModal(context, vehicle);
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: lPrimaryColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    // Utilisation d'Image.asset temporaire pour tes images locales
                    child: Image.asset(
                      vehicle.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.directions_car,
                        size: 60,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.isForRent
                          ? kPrimaryColor
                          : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      vehicle.isForRent ? "Location" : "Vente",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${vehicle.brand} ${vehicle.modelName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            " $rating",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 14,
                      ),
                      Text(
                        " ${vehicle.city}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceDisplay,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: vehicle.isForRent
                                  ? kPrimaryColor
                                  : Colors.orange.shade700,
                              fontSize: 14,
                            ),
                          ),
                          if (period.isNotEmpty)
                            Text(
                              period,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: vehicle.isForRent
                              ? kPrimaryColor
                              : Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
