import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/features/home/providers/home_provider.dart';
import 'package:kamer_drive_final/features/search/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../../../models/vehicle_model.dart';
import '../../../models/sale_booking_model.dart';
import '../providers/booking_provider.dart';

class SaleBookingScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const SaleBookingScreen({super.key, required this.vehicle});

  @override
  State<SaleBookingScreen> createState() => _SaleBookingScreenState();
}

class _SaleBookingScreenState extends State<SaleBookingScreen> {
  late TextEditingController _offerController;
  bool _isLoading = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _offerController = TextEditingController(
      text: widget.vehicle.salePrice?.toInt().toString() ?? "",
    );
  }

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  Future<void> _submitOffer() async {
    final offerText = _offerController.text.trim();
    if (offerText.isEmpty) {
      SnackbarUtils.showWarning(
        context,
        "Veuillez entrer un montant pour votre offre.",
      );
      return;
    }

    final offerAmount = double.tryParse(offerText);
    if (offerAmount == null || offerAmount <= 0) {
      SnackbarUtils.showError(context, "Montant invalide.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? "USER_TEST";
      final docId = FirebaseFirestore.instance
          .collection('sale_bookings')
          .doc()
          .id;

      final saleBooking = SaleBookingModel(
        id: docId,
        vehicleId: widget.vehicle.id,
        ownerId: widget.vehicle.ownerId,
        buyerId: currentUserId,
        agreedPrice: offerAmount,
        status: "Négociation",
        fundsReceived: false,
        vehicleReceived: false,
        ownershipTransferred: false,
        reviews: [],
        createdAt: DateTime.now(),
      );

      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).createSaleBooking(saleBooking);

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          "Votre offre a été envoyée ! Le propriétaire vous contactera.",
        );

        // --- NOUVEAU: Rafraîchir les listes ---
        context.read<HomeProvider>().fetchHomeData();
        context.read<SearchProvider>().fetchAllVehicles();

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, "Erreur lors de l'envoi de l'offre.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // --- HEADER VERT ARRONDIS ---
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 10,
              right: 10,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [kPrimaryColor, dPrimaryColor]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
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
                  "Contacter le vendeur",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENU PRINCIPAL ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CAROUSEL D'IMAGES
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PageView.builder(
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) =>
                                setState(() => _currentImageIndex = index),
                            itemCount: widget.vehicle.images.isNotEmpty
                                ? widget.vehicle.images.length
                                : 1,
                            itemBuilder: (context, index) {
                              if (widget.vehicle.images.isEmpty) {
                                return Container(
                                  color: lPrimaryColor,
                                  child: const Icon(
                                    Icons.directions_car,
                                    size: 80,
                                    color: kPrimaryColor,
                                  ),
                                );
                              }
                              return _buildImage(widget.vehicle.images[index]);
                            },
                          ),
                        ),
                        if (widget.vehicle.images.length > 1)
                          Positioned(
                            bottom: 10,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.vehicle.images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    height: 6,
                                    width: _currentImageIndex == index ? 16 : 6,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
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
                  ),
                  const SizedBox(height: 20),

                  // 2. INFOS VÉHICULE
                  Text(
                    "${widget.vehicle.brand} ${widget.vehicle.modelName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "${widget.vehicle.address}, ${widget.vehicle.city}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      _buildMiniSpec(Icons.settings, widget.vehicle.gearbox),
                      _buildMiniSpec(
                        Icons.local_gas_station,
                        widget.vehicle.fuelType,
                      ),
                      _buildMiniSpec(
                        Icons.calendar_month,
                        "Année ${widget.vehicle.year}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 15),

                  // 3. PRIX ET OFFRE (Mise en relation)
                  const Text(
                    "Faire une offre",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prix demandé :",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "${widget.vehicle.salePrice?.toInt() ?? 0} FCFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Votre proposition (FCFA)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _offerController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange.shade700,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          color: Colors.orange.shade700,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        suffixText: "FCFA",
                        suffixStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Le vendeur recevra cette offre et pourra vous contacter pour finaliser la vente.",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. CONSEILS SÉCURITÉ (Hors plateforme)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Conseils de sécurité",
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildSecurityStep(
                          "1",
                          "Votre offre sert de premier contact avec le vendeur.",
                        ),
                        _buildSecurityStep(
                          "2",
                          "Prenez toujours rendez-vous dans un lieu public pour voir le véhicule.",
                        ),
                        _buildSecurityStep(
                          "3",
                          "Vérifiez minutieusement les documents du véhicule avant tout paiement.",
                        ),
                        _buildSecurityStep(
                          "4",
                          "Le paiement se fait directement entre vous et le vendeur. KamerDrive n'intervient pas dans le transfert de fonds.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- BOUTON ENVOYER L'OFFRE ---
      bottomSheet: Container(
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
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Envoyer mon offre",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    );
  }

  Widget _buildSecurityStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
