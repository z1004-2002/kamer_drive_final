import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/features/notifications/providers/notification_provider.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';
import 'package:kamer_drive_final/shared/widgets/vehicle_details_modal.dart';
import 'package:provider/provider.dart';
import '../../../models/vehicle_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;

  const HomeScreen({super.key, required this.onNavigateToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // On demande au provider de charger les données au chargement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Écoute de l'utilisateur connecté pour le Header
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userName = currentUser?.firstName ?? "Utilisateur";

    // Écoute des données du HomeProvider
    final homeProvider = context.watch<HomeProvider>();
    final rentalVehicles = homeProvider.recentRentalVehicles;
    final saleVehicles = homeProvider.recentSaleVehicles;
    final isLoading = homeProvider.isLoading;

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
              // NOUVEAU HEADER (Intègre maintenant la barre de recherche)
              _buildFixedHeader(userName, widget.onNavigateToSearch),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: kPrimaryColor,
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      top: 15,
                      bottom: 40,
                    ), // J'ai réduit le padding bas vu que la barre n'y est plus
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- SECTION LOCATION ---
                        _buildSectionTitle(
                          "Véhicules en Location",
                          () => widget.onNavigateToSearch(),
                        ),

                        if (isLoading && rentalVehicles.isEmpty)
                          const SizedBox(
                            height: 260,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            ),
                          )
                        else if (rentalVehicles.isEmpty)
                          _buildEmptyStateMessage(
                            "Rien à louer pour le moment",
                            "Les véhicules disponibles à la location apparaîtront ici.",
                            Icons.car_rental,
                          )
                        else
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: 20),
                              itemCount: rentalVehicles.length,
                              itemBuilder: (context, index) =>
                                  _buildVehicleCard(
                                    rentalVehicles[index],
                                    isRentContext: true,
                                    onTap: () {
                                      showVehicleDetailsModal(
                                        context,
                                        rentalVehicles[index],
                                        isRentContext: true,
                                        isOwnerView: false,
                                      );
                                    },
                                  ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // --- SECTION VENTE ---
                        _buildSectionTitle(
                          "Véhicules à Vendre",
                          () => widget.onNavigateToSearch(),
                        ),

                        if (isLoading && saleVehicles.isEmpty)
                          const SizedBox(
                            height: 260,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          )
                        else if (saleVehicles.isEmpty)
                          _buildEmptyStateMessage(
                            "Aucune voiture à vendre",
                            "Les véhicules mis en vente par les propriétaires s'afficheront ici.",
                            Icons.sell_outlined,
                          )
                        else
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: 20),
                              itemCount: saleVehicles.length,
                              itemBuilder: (context, index) =>
                                  _buildVehicleCard(
                                    saleVehicles[index],
                                    isRentContext: false,
                                    onTap: () {
                                      showVehicleDetailsModal(
                                        context,
                                        saleVehicles[index],
                                        isRentContext: false,
                                        isOwnerView: false,
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

  // --- LE NOUVEAU HEADER MAGIQUE ---
  Widget _buildFixedHeader(String userName, VoidCallback onSearch) {
    final int unreadCount = context.watch<NotificationProvider>().unreadCount;
    return SizedBox(
      height:
          215, // La hauteur totale laisse de la place pour la barre de recherche
      child: Stack(
        children: [
          // Le fond vert (S'arrête un peu avant la fin pour laisser déborder la barre)
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
                    // --- LA CLOCHE DE NOTIFICATION MODIFIÉE ---
                    GestureDetector(
                      onTap: () {
                        // Ouvre la page des notifications
                        context.push('/notifications');
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
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

                          // LE BADGE ROUGE (S'affiche uniquement s'il y a des notifs)
                          if (unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  unreadCount > 9
                                      ? "9+"
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // ------------------------------------------
                  ],
                ),
              ),
            ),
          ),

          // LA BARRE DE RECHERCHE ICI
          Positioned(
            bottom: 5,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: onSearch,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 5),
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.08),
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
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lPrimaryColor,
                        borderRadius: BorderRadius.circular(15),
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

  Widget _buildVehicleCard(
    VehicleModel vehicle, {
    required bool isRentContext,
    required VoidCallback onTap,
  }) {
    String priceDisplay = isRentContext
        ? "${vehicle.rentPricePerDay?.toInt() ?? 0} FCFA"
        : "${vehicle.salePrice?.toInt() ?? 0} FCFA";
    String period = isRentContext ? "/jour" : "";

    Color themeColor = isRentContext ? kPrimaryColor : Colors.orange.shade600;
    String badgeText = isRentContext ? "Location" : "Vente";

    double rating = vehicle.reviews.isEmpty ? 4.8 : 4.8;

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
                    child:
                        vehicle.images.isNotEmpty &&
                            vehicle.images.first.startsWith('http')
                        ? Image.network(
                            vehicle.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.directions_car,
                              size: 60,
                              color: kPrimaryColor,
                            ),
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
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
                      color: themeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
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
                          color: themeColor,
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
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimaryColor, size: 35),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
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
  }

  Future<void> _refreshData() async {
    await context.read<HomeProvider>().fetchHomeData();
  }
}
