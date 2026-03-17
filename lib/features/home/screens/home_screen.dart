import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;

  const HomeScreen({super.key, required this.onNavigateToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Récupération des données depuis la base de données via le Provider
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userName = currentUser?.firstName ?? "Utilisateur";

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // --- CERCLES DÉCORATIFS EN FOND ---
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

          // --- LE CONTENU PRINCIPAL ---
          Column(
            children: [
              // 1. LE HEADER FIXE CORRIGÉ
              _buildFixedHeader(userName),

              // 2. LE CONTENU SCROLLABLE
              // L'utilisation de Expanded garantit que le texte disparaît pile en dessous du header
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 80,
                  ), // Top padding réduit pour être proche de la barre
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        "Véhicules en Location",
                        () => widget.onNavigateToSearch(),
                      ),
                      SizedBox(
                        height: 260,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 20),
                          children: [
                            _buildVehicleCard(
                              model: "Toyota Corolla 2021",
                              price: "35.000 FCFA",
                              period: "/jour",
                              rating: 4.8,
                              imagePath: "assets/images/cars/car1.jpg",
                              city: "Douala",
                              isRental: true,
                            ),
                            _buildVehicleCard(
                              model: "Hyundai Tucson",
                              price: "60.000 FCFA",
                              period: "/jour",
                              rating: 4.5,
                              imagePath: "assets/images/cars/car2.jpg",
                              city: "Yaoundé",
                              isRental: true,
                            ),
                            _buildVehicleCard(
                              model: "Toyota Corolla 2021",
                              price: "35.000 FCFA",
                              period: "/jour",
                              rating: 4.8,
                              imagePath: "assets/images/cars/car1.jpg",
                              city: "Douala",
                              isRental: true,
                            ),
                            _buildVehicleCard(
                              model: "Hyundai Tucson",
                              price: "60.000 FCFA",
                              period: "/jour",
                              rating: 4.5,
                              imagePath: "assets/images/cars/car2.jpg",
                              city: "Yaoundé",
                              isRental: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        "Véhicules à Vendre",
                        () => widget.onNavigateToSearch(),
                      ),
                      SizedBox(
                        height: 260,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 20),
                          children: [
                            _buildVehicleCard(
                              model: "Mercedes-Benz C300",
                              price: "15.000.000 FCFA",
                              period: "",
                              rating: 4.9,
                              imagePath: "assets/images/cars/car2.jpg",
                              city: "Douala",
                              isRental: false,
                            ),
                            _buildVehicleCard(
                              model: "Kia Sportage 2020",
                              price: "12.500.000 FCFA",
                              period: "",
                              rating: 5.0,
                              imagePath: "assets/images/cars/car1.jpg",
                              city: "Bafoussam",
                              isRental: false,
                            ),
                            _buildVehicleCard(
                              model: "Mercedes-Benz C300",
                              price: "15.000.000 FCFA",
                              period: "",
                              rating: 4.9,
                              imagePath: "assets/images/cars/car2.jpg",
                              city: "Douala",
                              isRental: false,
                            ),
                            _buildVehicleCard(
                              model: "Kia Sportage 2020",
                              price: "12.500.000 FCFA",
                              period: "",
                              rating: 5.0,
                              imagePath: "assets/images/cars/car1.jpg",
                              city: "Bafoussam",
                              isRental: false,
                            ),
                          ],
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

  // --- LE HEADER FIXE (LA CORRECTION EST ICI) ---
  Widget _buildFixedHeader(String userName) {
    // On force la hauteur globale du header à 215 (190 de fond vert + 25 de barre de recherche)
    return SizedBox(
      height: 195,
      child: Stack(
        children: [
          // Le fond dégradé vert (Hauteur de 190)
          Container(
            height: 170,
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

          // La barre de recherche
          // Elle est désormais "posée" tout en bas du SizedBox (à la position 0),
          // elle dépasse donc visuellement de 25 pixels du fond vert, mais est contenue dans le SizedBox global.
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

  // --- TITRE DE SECTION ---
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

  // --- CARTE DE VÉHICULE ---
  Widget _buildVehicleCard({
    required String model,
    required String price,
    required String period,
    required double rating,
    required String imagePath,
    required String city,
    required bool isRental,
  }) {
    return Container(
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
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
                    color: isRental ? kPrimaryColor : Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isRental ? "Location" : "Vente",
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
                        model,
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
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    Text(
                      " $city",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRental
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
                    GestureDetector(
                      onTap: () {
                        print("Ouvrir les détails de $model");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isRental
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
