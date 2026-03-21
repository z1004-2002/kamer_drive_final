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
  //  List<VehicleModel> _rentalVehicles = [];
  //  List<VehicleModel> _saleVehicles = [];
  List<VehicleModel> _rentalVehicles = [
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
      withDriverOption: true,
      rentPriceWithDriver: 50000,
      securityDeposit:
          5000000, // Attention, 5 millions de caution pour une Corolla ça pique un peu ! 😁
      isForSale: true,
      salePrice: 15000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
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
      withDriverOption: false,
      securityDeposit: 4000000,
      isForSale: false,
      seats: 4,
      gearbox: "Automatique",
      fuelType: "Diesel",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    VehicleModel(
      id: "1_dup", // J'ai légèrement modifié l'ID pour éviter les conflits dans Flutter
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
      securityDeposit: 4500000,
      withDriverOption: true,
      rentPriceWithDriver: 50000,
      isForSale: false,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  List<VehicleModel> _saleVehicles = [
    VehicleModel(
      id: "3_sale_1",
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
      withDriverOption: false,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
    ),
    VehicleModel(
      id: "1_sale",
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
      withDriverOption: true,
      rentPriceWithDriver: 50000,
      securityDeposit: 300000, // Je l'ai un peu baissée ici 😉
      isForSale: true,
      salePrice: 15000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),
    VehicleModel(
      id: "3_sale_2",
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
      withDriverOption: false,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
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

          Column(
            children: [
              _buildFixedHeader(userName),

              Expanded(
                // 1. ON AJOUTE LE REFRESH INDICATOR ICI
                child: RefreshIndicator(
                  onRefresh: _refreshData, // Appel de notre fonction
                  color: kPrimaryColor, // Couleur du petit cercle de chargement
                  backgroundColor: Colors.white,

                  child: SingleChildScrollView(
                    // 2. ASTUCE CRUCIALE : AlwaysScrollableScrollPhysics
                    // Cela force la page à être "scrollable" même s'il n'y a pas assez
                    // de voitures pour remplir l'écran, permettant au RefreshIndicator de fonctionner.
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(top: 15, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION LOCATION
                        _buildSectionTitle(
                          "Véhicules en Location",
                          () => widget.onNavigateToSearch(),
                        ),
                        _rentalVehicles.isEmpty
                            ? _buildEmptyStateMessage(
                                "Rien à louer pour le moment",
                                "Les véhicules disponibles à la location apparaîtront ici.",
                                Icons.car_rental,
                              )
                            : SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 20),
                                  itemCount: _rentalVehicles.length,
                                  itemBuilder: (context, index) => _buildVehicleCard(
                                    _rentalVehicles[index],
                                    isRentContext: true,
                                    onTap: () {
                                      // APPEL DE LA MODAL
                                      showVehicleDetailsModal(
                                        context,
                                        _rentalVehicles[index],
                                        isRentContext:
                                            true, // Contexte Location pour la modal
                                        isOwnerView:
                                            false, // On cache le prix de vente si le client loue
                                      );
                                    },
                                  ),
                                ),
                              ),

                        const SizedBox(height: 20),

                        // SECTION VENTE
                        _buildSectionTitle(
                          "Véhicules à Vendre",
                          () => widget.onNavigateToSearch(),
                        ),
                        _saleVehicles.isEmpty
                            ? _buildEmptyStateMessage(
                                "Aucune voiture à vendre",
                                "Les véhicules mis en vente par les propriétaires s'afficheront ici.",
                                Icons.sell_outlined,
                              )
                            : SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 20),
                                  itemCount: _saleVehicles.length,
                                  itemBuilder: (context, index) => _buildVehicleCard(
                                    _saleVehicles[index],
                                    isRentContext: false,
                                    onTap: () {
                                      // APPEL DE LA MODAL
                                      showVehicleDetailsModal(
                                        context,
                                        _saleVehicles[index],
                                        isRentContext:
                                            false, // Contexte Vente pour la modal
                                        isOwnerView:
                                            false, // On cache le prix de location
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ),
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
  // Ajout du paramètre isRentContext
  Widget _buildVehicleCard(
    VehicleModel vehicle, {
    required bool isRentContext,
    required VoidCallback onTap,
  }) {
    // 1. On définit l'affichage en fonction du CONTEXTE (Location ou Vente)
    String priceDisplay = isRentContext
        ? "${vehicle.rentPricePerDay?.toInt() ?? 0} FCFA"
        : "${vehicle.salePrice?.toInt() ?? 0} FCFA";
    String period = isRentContext ? "/jour" : "";

    Color themeColor = isRentContext ? kPrimaryColor : Colors.orange.shade600;
    String badgeText = isRentContext ? "Location" : "Vente";

    double rating = vehicle.reviews.isEmpty
        ? 4.8
        : 4.8; // Simplifié pour le design

    return GestureDetector(
      onTap: onTap,
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
                    // N'oublie pas de remettre Image.network quand tu passeras aux vraies données !
                    child: Image.asset(
                      vehicle.images.isNotEmpty
                          ? vehicle.images.first
                          : 'assets/images/placeholder.png',
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
                      color: themeColor, // Utilisation de la couleur dynamique
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText, // Texte dynamique
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
                              color: themeColor,
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
                          color:
                              themeColor, // Utilisation de la couleur dynamique
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

  // --- WIDGET HELPER : MESSAGE STATIQUE SI LISTE VIDE ---
  Widget _buildEmptyStateMessage(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône dans un cercle aux couleurs de l'appli
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimaryColor, size: 35),
          ),
          const SizedBox(height: 15),

          // Titre principal
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Sous-titre explicatif
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  } // --- FONCTION DE RAFRAÎCHISSEMENT ---

  Future<void> _refreshData() async {
    // Si tu as connecté ton VehicleProvider, c'est ici que tu rappelles la base de données.
    // Exemple : await Provider.of<VehicleProvider>(context, listen: false).fetchHomeVehicles();

    // Pour l'instant, on simule un temps de chargement de 1.5 secondes
    await Future.delayed(const Duration(milliseconds: 1500));

    // On met à jour l'interface (setState) pour refléter les nouvelles données
    if (mounted) {
      setState(() {
        _rentalVehicles = _rentalVehicles;
        _saleVehicles = _saleVehicles;
      });
    }
  }
}
