import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/features/home/providers/home_provider.dart';
import 'package:kamer_drive_final/features/search/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/vehicle_model.dart';
import '../../../models/rental_booking_model.dart';
import '../providers/booking_provider.dart';

class RentalBookingScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const RentalBookingScreen({super.key, required this.vehicle});

  @override
  State<RentalBookingScreen> createState() => _RentalBookingScreenState();
}

class _RentalBookingScreenState extends State<RentalBookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includesDriver = false;
  bool _isLoading = false;
  int _currentImageIndex = 0;

  final double _driverFeePerDay = 15000;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  int get _numberOfDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    double basePrice = _numberOfDays * (widget.vehicle.rentPricePerDay ?? 0);
    double driverTotal = _includesDriver
        ? (_numberOfDays * _driverFeePerDay)
        : 0;
    return basePrice + driverTotal;
  }

  // In lib/screens/booking/screens/rental_booking_screen.dart

  Future<void> _submitBooking() async {
    if (_startDate == null || _endDate == null) {
      SnackbarUtils.showWarning(context, "Veuillez sélectionner vos dates.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? "USER_TEST";
      final docId = FirebaseFirestore.instance
          .collection('rental_bookings')
          .doc()
          .id;

      final booking = RentalBookingModel(
        id: docId,
        vehicleId: widget.vehicle.id,
        ownerId: widget.vehicle.ownerId,
        tenantId: currentUserId,
        startDate: _startDate!,
        endDate: _endDate!,
        includesDriver: _includesDriver,
        totalPrice: _totalPrice,
        securityDeposit: widget.vehicle.securityDeposit ?? 0,
        status: "En attente",
        checkInValidated: false,
        checkOutValidated: false,
        depositRefunded: false,
        reviews: [],
        createdAt: DateTime.now(),
      );

      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).createRentalBooking(booking);

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          "Demande envoyée ! Le propriétaire vous contactera.",
        );

        // --- NOUVEAU: Rafraîchir les listes avant de quitter ---
        // Si l'utilisateur vient de Home:
        context.read<HomeProvider>().fetchHomeData();
        // Si l'utilisateur vient de Search:
        context.read<SearchProvider>().fetchAllVehicles();

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, "Erreur lors de la réservation.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  "Réserver ce véhicule",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${widget.vehicle.brand} ${widget.vehicle.modelName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Text(
                        "${widget.vehicle.rentPricePerDay?.toInt()} FCFA/j",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 18,
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
                        Icons.airline_seat_recline_normal,
                        "${widget.vehicle.seats} Places",
                      ),
                      if (widget.vehicle.hasAC)
                        _buildMiniSpec(Icons.ac_unit, "Climatisé"),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 3. SÉLECTION DES DATES
                  const Text(
                    "Vos dates de location",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              _startDate == null
                                  ? "Appuyez pour choisir vos dates"
                                  : "${DateFormat('dd/MM/yyyy').format(_startDate!)}  au  ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                              style: TextStyle(
                                fontSize: 15,
                                color: _startDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: _startDate == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. OPTION CHAUFFEUR
                  if (widget.vehicle.withDriverOption == true) ...[
                    const Text(
                      "Options supplémentaires",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Ajouter un chauffeur",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          "+$_driverFeePerDay FCFA / jour",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        activeColor: kPrimaryColor,
                        value: _includesDriver,
                        onChanged: (val) =>
                            setState(() => _includesDriver = val),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // 5. ESTIMATION (Pas de paiement in-app)
                  const Text(
                    "Estimation du coût",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow(
                          "Location ($_numberOfDays jours)",
                          "${(_numberOfDays * (widget.vehicle.rentPricePerDay ?? 0)).toInt()} FCFA",
                        ),
                        if (_includesDriver) ...[
                          const SizedBox(height: 10),
                          _buildReceiptRow(
                            "Chauffeur ($_numberOfDays jours)",
                            "${(_numberOfDays * _driverFeePerDay).toInt()} FCFA",
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(),
                        ),
                        _buildReceiptRow(
                          "Total estimé",
                          "${_totalPrice.toInt()} FCFA",
                          isTotal: true,
                        ),

                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.handshake_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Le paiement s'effectuera directement avec le propriétaire lors de la remise des clés.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Encart Caution
                        if ((widget.vehicle.securityDeposit ?? 0) > 0) ...[
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Caution remboursable",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${widget.vehicle.securityDeposit!.toInt()} FCFA vous seront demandés en garantie.",
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

      // --- BOUTON DEMANDER ---
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
              onPressed: _isLoading ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
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
                      "Envoyer la demande",
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

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? kPrimaryColor : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
