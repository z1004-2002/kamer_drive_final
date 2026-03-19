import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String _selectedGearbox = "Toutes"; // 'Toutes', 'Automatique', 'Manuelle'
  String _selectedFuel =
      "Tous"; // 'Tous', 'Essence', 'Diesel', 'Hybride', 'Électrique'
  double _minSeats = 2;
  bool _requireAC = false;

  // Plages de prix par défaut
  RangeValues _rentPriceRange = const RangeValues(10000, 200000);
  RangeValues _salePriceRange = const RangeValues(1000000, 50000000);

  // --- DONNÉES STATIQUES POUR LE TEST ---
  final List<VehicleModel> _staticVehicles = [
    VehicleModel(
      id: "1",
      ownerId: "owner1",
      brand: "Toyota",
      modelName: "RAV4",
      year: 2021,
      city: "Yaoundé",
      address: "Bastos",
      images: ['assets/images/cars/car1.jpg'],
      description: "Superbe RAV4 récent, très confortable.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 45000,
      securityDeposit: 100000,
      withDriverOption: true,
      isForSale: false,
      salePrice: null,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "2",
      ownerId: "owner2",
      brand: "Mercedes",
      modelName: "Classe C",
      year: 2019,
      city: "Douala",
      address: "Bonapriso",
      images: ['assets/images/cars/car2.jpg'],
      description: "Berline de luxe idéale pour les mariages ou VIP.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 80000,
      securityDeposit: 200000,
      withDriverOption: true,
      isForSale: true,
      salePrice: 18000000,
      seats: 5,
      gearbox: "Automatique",
      fuelType: "Essence",
      hasAC: true,
      reviews: [],
    ),
    VehicleModel(
      id: "3",
      ownerId: "owner3",
      brand: "Suzuki",
      modelName: "Alto",
      year: 2015,
      city: "Yaoundé",
      address: "Essos",
      images: ['assets/images/cars/car1.jpg'],
      description: "Petite citadine économique, parfaite pour la ville.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: false,
      rentPricePerDay: null,
      securityDeposit: null,
      withDriverOption: false,
      isForSale: true,
      salePrice: 3500000,
      seats: 4,
      gearbox: "Manuelle",
      fuelType: "Essence",
      hasAC: false,
      reviews: [],
    ),
    VehicleModel(
      id: "4",
      ownerId: "owner4",
      brand: "Toyota",
      modelName: "Prado",
      year: 2020,
      city: "Douala",
      address: "Akwa",
      images: ['assets/images/cars/car2.jpg'],
      description: "4x4 robuste pour tous les terrains.",
      registrationPlateUrl: "",
      registrationDocumentUrl: "",
      insuranceCertificateUrl: "",
      validationStatus: "Validé",
      isForRent: true,
      rentPricePerDay: 100000,
      securityDeposit: 300000,
      withDriverOption: true,
      isForSale: false,
      salePrice: null,
      seats: 7,
      gearbox: "Automatique",
      fuelType: "Diesel",
      hasAC: true,
      reviews: [],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  }

  // --- LOGIQUE DE FILTRAGE ---
  List<VehicleModel> _filterVehicles(List<VehicleModel> vehicles) {
    return vehicles.where((v) {
      if (v.validationStatus.toLowerCase() != 'validé' &&
          v.validationStatus.toLowerCase() != 'valide')
        return false;

      // 1. Recherche textuelle
      if (_searchQuery.isNotEmpty) {
        String fullName = "${v.brand} ${v.modelName}".toLowerCase();
        if (!fullName.contains(_searchQuery.toLowerCase())) return false;
      }

      // 2. Filtres Basiques
      if (_transactionType == 'rent' && !v.isForRent) return false;
      if (_transactionType == 'sale' && !v.isForSale) return false;
      if (_selectedBrand != 'Toutes' && v.brand != _selectedBrand) return false;
      if (_selectedGearbox != 'Toutes' && v.gearbox != _selectedGearbox)
        return false;
      if (_selectedFuel != 'Tous' && v.fuelType != _selectedFuel) return false;
      if (v.seats < _minSeats) return false;
      if (_requireAC && !v.hasAC) return false;

      // 3. Filtres de Prix
      if (_transactionType == 'rent' && v.rentPricePerDay != null) {
        if (v.rentPricePerDay! < _rentPriceRange.start ||
            v.rentPricePerDay! > _rentPriceRange.end)
          return false;
      }
      if (_transactionType == 'sale' && v.salePrice != null) {
        if (v.salePrice! < _salePriceRange.start ||
            v.salePrice! > _salePriceRange.end)
          return false;
      }

      return true;
    }).toList();
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
                          if (_transactionType == 'rent') ...[
                            Text(
                              "Prix par jour : ${_rentPriceRange.start.toInt()} à ${_rentPriceRange.end.toInt()} FCFA",
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
                          ] else if (_transactionType == 'sale') ...[
                            Text(
                              "Budget : ${(_salePriceRange.start / 1000000).toStringAsFixed(1)}M à ${(_salePriceRange.end / 1000000).toStringAsFixed(1)}M FCFA",
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

                          // 3. MARQUE (Scrolling horizontal)
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
                            children: ["Toutes", "Automatique", "Manuelle"]
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

                          // 5. AUTRES (Places & Clim)
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
                          setState(() {}); // Met à jour la liste des résultats
                          Navigator.pop(context); // Ferme la modal
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Voir les résultats",
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

    // On applique le filtre sur nos données statiques
    final filteredList = _filterVehicles(_staticVehicles);

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
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.arrow_back_ios_new,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: () => context.pop(),
                    // ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
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

              // --- COMPTEUR DE RÉSULTATS ---
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "${filteredList.length} résultat(s) trouvé(s)",
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
                child: filteredList.isEmpty
                    ? _buildEmptyMessage()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 40,
                          left: 20,
                          right: 20,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) =>
                            _buildSearchResultCard(filteredList[index]),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NOUVELLE CARTE DE RÉSULTAT (Style épuré avec la vraie Image) ---
  Widget _buildSearchResultCard(VehicleModel vehicle) {
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
        // padding: const EdgeInsets.all(12),
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
            // IMAGE (Remplaçant l'icône, beau format carré/arrondi)
            Container(
              width: 110,
              height: double.infinity,
              decoration: BoxDecoration(
                color: lPrimaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                // Ici on utilise .asset car ce sont nos données statiques
                child: Image.asset(
                  vehicle.images.isNotEmpty
                      ? vehicle.images.first
                      : 'assets/images/placeholder.jpg',
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

            // INFOS (Style épuré)
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

                  // Caractéristiques (Boîte et Carburant)
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
                setState(() {
                  _searchQuery = "";
                  _transactionType = "all";
                  _selectedBrand = "Toutes";
                  _selectedGearbox = "Toutes";
                  _selectedFuel = "Tous";
                  _minSeats = 2;
                  _requireAC = false;
                  _rentPriceRange = const RangeValues(10000, 200000);
                  _salePriceRange = const RangeValues(1000000, 50000000);
                });
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
