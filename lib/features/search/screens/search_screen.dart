import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/features/search/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/vehicle_details_modal.dart';
import '../../../models/vehicle_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // --- ÉTATS DES FILTRES ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  String _transactionType = "all"; // 'all', 'rent', 'sale'
  String _selectedBrand = "Toutes";
  String _selectedGearbox = "Toutes"; // Contient bien 'Semi-automatique'
  String _selectedFuel = "Tous";
  double _minSeats = 2;
  bool _requireAC = false;

  RangeValues _rentPriceRange = const RangeValues(10000, 200000);
  RangeValues _salePriceRange = const RangeValues(1000000, 50000000);

  @override
  void initState() {
    super.initState();
    // On charge les données depuis Firebase au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().fetchAllVehicles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIQUE POUR DÉCLENCHER LE FILTRE ---
  void _triggerFilter() {
    context.read<SearchProvider>().applyFilters(
      searchQuery: _searchQuery,
      transactionType: _transactionType,
      brand: _selectedBrand,
      gearbox: _selectedGearbox,
      fuelType: _selectedFuel,
      minSeats: _minSeats,
      requireAC: _requireAC,
      rentPriceRange: _rentPriceRange,
      salePriceRange: _salePriceRange,
    );
  }

  // --- LOGIQUE DE RÉINITIALISATION ---
  void _resetFilters(StateSetter setModalState) {
    setModalState(() {
      _transactionType = "all";
      _selectedBrand = "Toutes";
      _selectedGearbox = "Toutes";
      _selectedFuel = "Tous";
      _minSeats = 2;
      _requireAC = false;
      _rentPriceRange = const RangeValues(10000, 200000);
      _salePriceRange = const RangeValues(1000000, 50000000);
    });
    _triggerFilter();
  }

  // --- MODAL DES FILTRES ---
  void _showFilterModal() {
    List<String> brands = [
      "Toutes",
      "Toyota",
      "Mercedes",
      "Suzuki",
      "Hyundai",
      "Kia",
      "Lexus",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // HEADER FILTRES + BOUTON RÉINITIALISER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtres",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _resetFilters(setModalState),
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          "Réinitialiser",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // 1. TRANSACTION TYPE
                          const Text(
                            "Type de transaction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildFilterChip(
                                "Tout",
                                "all",
                                _transactionType,
                                (v) =>
                                    setModalState(() => _transactionType = v),
                              ),
                              const SizedBox(width: 10),
                              _buildFilterChip(
                                "Louer",
                                "rent",
                                _transactionType,
                                (v) =>
                                    setModalState(() => _transactionType = v),
                              ),
                              const SizedBox(width: 10),
                              _buildFilterChip(
                                "Acheter",
                                "sale",
                                _transactionType,
                                (v) =>
                                    setModalState(() => _transactionType = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // 2. PRIX (Adaptatif)
                          if (_transactionType == 'rent' ||
                              _transactionType == 'all') ...[
                            Text(
                              "Prix location : ${_rentPriceRange.start.toInt()} à ${_rentPriceRange.end.toInt()} FCFA/j",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            RangeSlider(
                              values: _rentPriceRange,
                              min: 5000,
                              max: 200000,
                              divisions: 39,
                              activeColor: kPrimaryColor,
                              onChanged: (values) =>
                                  setModalState(() => _rentPriceRange = values),
                            ),
                            const SizedBox(height: 25),
                          ],

                          if (_transactionType == 'sale' ||
                              _transactionType == 'all') ...[
                            Text(
                              "Budget achat : ${(_salePriceRange.start / 1000000).toStringAsFixed(1)}M à ${(_salePriceRange.end / 1000000).toStringAsFixed(1)}M FCFA",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            RangeSlider(
                              values: _salePriceRange,
                              min: 500000,
                              max: 50000000,
                              divisions: 99,
                              activeColor: Colors.orange,
                              onChanged: (values) =>
                                  setModalState(() => _salePriceRange = values),
                            ),
                            const SizedBox(height: 25),
                          ],

                          // 3. MARQUE
                          const Text(
                            "Marque",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: brands
                                  .map(
                                    (b) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildFilterChip(
                                        b,
                                        b,
                                        _selectedBrand,
                                        (v) => setModalState(
                                          () => _selectedBrand = v,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // 4. BOÎTE & CARBURANT
                          const Text(
                            "Boîte de vitesse",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                [
                                      "Toutes",
                                      "Automatique",
                                      "Manuelle",
                                      "Semi-automatique",
                                    ]
                                    .map(
                                      (box) => _buildFilterChip(
                                        box,
                                        box,
                                        _selectedGearbox,
                                        (v) => setModalState(
                                          () => _selectedGearbox = v,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 25),

                          const Text(
                            "Carburant",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                [
                                      "Tous",
                                      "Essence",
                                      "Diesel",
                                      "Hybride",
                                      "Électrique",
                                    ]
                                    .map(
                                      (fuel) => _buildFilterChip(
                                        fuel,
                                        fuel,
                                        _selectedFuel,
                                        (v) => setModalState(
                                          () => _selectedFuel = v,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 25),

                          // 5. AUTRES
                          const Text(
                            "Autres critères",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Nombre de places min. : ${_minSeats.toInt()}",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              Slider(
                                value: _minSeats,
                                min: 2,
                                max: 8,
                                divisions: 6,
                                activeColor: kPrimaryColor,
                                onChanged: (val) =>
                                    setModalState(() => _minSeats = val),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Climatisation requise"),
                            activeColor: kPrimaryColor,
                            value: _requireAC,
                            onChanged: (val) =>
                                setModalState(() => _requireAC = val),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // BOUTON APPLIQUER
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          _triggerFilter(); // Déclenche le filtrage
                          Navigator.pop(context); // Ferme la modal
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Appliquer les filtres",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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

  Widget _buildFilterChip(
    String label,
    String value,
    String groupValue,
    Function(String) onTap,
  ) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Background UI
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

          Column(
            children: [
              // --- HEADER RECHERCHE ---
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 20,
                  left: 15,
                  right: 15,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, dPrimaryColor],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
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
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            _searchQuery = val;
                            _triggerFilter(); // Recherche temps réel !
                          },
                          decoration: InputDecoration(
                            hintText: "Toyota, Mercedes...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: kPrimaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // --- ÉTATS DE CHARGEMENT / COMPTEUR ---
              if (searchProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: Row(
                    children: [
                      Text(
                        "${searchProvider.filteredVehicles.length} résultat(s) trouvé(s) (Max. 30)",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LISTE DES RÉSULTATS ---
                Expanded(
                  child: searchProvider.filteredVehicles.isEmpty
                      ? _buildEmptyMessage()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 40,
                            left: 20,
                            right: 20,
                          ),
                          itemCount: searchProvider.filteredVehicles.length,
                          itemBuilder: (context, index) =>
                              _buildSearchResultCard(
                                searchProvider.filteredVehicles[index],
                              ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- CARTE DE RÉSULTAT ---
  Widget _buildSearchResultCard(VehicleModel vehicle) {
    // Logique adaptative : si on est sur "Tout", on priorise l'affichage Location s'il est dispo, sinon Vente.
    bool isRentContext =
        _transactionType == 'rent' ||
        (_transactionType == 'all' && vehicle.isForRent);
    Color themeColor = isRentContext ? kPrimaryColor : Colors.orange.shade700;

    return GestureDetector(
      onTap: () => showVehicleDetailsModal(
        context,
        vehicle,
        isRentContext: isRentContext,
        isOwnerView: false,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // IMAGE
            Container(
              width: 110,
              height: double.infinity,
              decoration: BoxDecoration(
                color: lPrimaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(15),
                ),
                child:
                    vehicle.images.isNotEmpty &&
                        vehicle.images.first.startsWith('http')
                    ? Image.network(
                        vehicle.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.directions_car,
                          size: 30,
                          color: kPrimaryColor,
                        ),
                      )
                    : Image.asset(
                        'assets/images/placeholder.png', // Image de secours
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.directions_car,
                          size: 30,
                          color: kPrimaryColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 15),

            // INFOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${vehicle.brand} ${vehicle.modelName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(Icons.settings, size: 12, color: Colors.grey),
                      Text(
                        " ${vehicle.gearbox} • ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.local_gas_station,
                        size: 12,
                        color: Colors.grey,
                      ),
                      Text(
                        " ${vehicle.fuelType}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // PRIX
                  if (isRentContext && vehicle.rentPricePerDay != null)
                    Text(
                      "${vehicle.rentPricePerDay!.toInt()} FCFA /j",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        fontSize: 14,
                      ),
                    )
                  else if (!isRentContext && vehicle.salePrice != null)
                    Text(
                      "${vehicle.salePrice!.toInt()} FCFA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        fontSize: 14,
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

  Widget _buildEmptyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "Aucun véhicule ne correspond à vos filtres.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                // On simule une modale (null) juste pour utiliser le setState interne à notre widget
                _resetFilters((fn) => setState(fn));
              },
              icon: const Icon(Icons.refresh, color: kPrimaryColor),
              label: const Text(
                "Effacer les filtres",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
