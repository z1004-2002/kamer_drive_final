import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // --- CONTRÔLEURS ---
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seatsController = TextEditingController();
  final _securityDepositController = TextEditingController();

  // --- ÉTATS ---
  bool _isForRent = false;
  bool _isForSale = false;
  bool _hasAC = true;
  String _selectedGearbox = "Manuelle";
  String _selectedFuel = "Essence";

  // --- IMAGES ---
  final ImagePicker _picker = ImagePicker();
  File? _imgFront, _imgBack, _imgLeft, _imgRight, _imgInterior;
  File? _docPlate, _docRegistration, _docInsurance;

  @override
  void dispose() {
    for (var controller in [
      _brandController,
      _modelController,
      _yearController,
      _rentPriceController,
      _salePriceController,
      _cityController,
      _addressController,
      _descriptionController,
      _seatsController,
      _securityDepositController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) setState(() => onSelected(File(image.path)));
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_brandController.text.isEmpty ||
          _modelController.text.isEmpty ||
          _yearController.text.isEmpty) {
        return SnackbarUtils.showWarning(
          context,
          "Complétez les infos et choisissez une intention.",
        );
      }
    } else if (_currentStep == 1) {
      if (_cityController.text.isEmpty || _descriptionController.text.isEmpty) {
        return SnackbarUtils.showWarning(
          context,
          "Indiquez au moins la ville et une description.",
        );
      }
    } else if (_currentStep == 2) {
      if (_imgFront == null ||
          _imgBack == null ||
          _imgLeft == null ||
          _imgRight == null ||
          _imgInterior == null) {
        return SnackbarUtils.showWarning(
          context,
          "Toutes les photos sont obligatoires.",
        );
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _submitVehicle();
    }
  }

  Future<void> _submitVehicle() async {
    if (_docPlate == null ||
        _docRegistration == null ||
        _docInsurance == null) {
      return SnackbarUtils.showWarning(context, "Documents manquants.");
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<VehicleProvider>(context, listen: false).submitVehicle(
        brand: _brandController.text.trim(),
        modelName: _modelController.text.trim(),
        year: int.tryParse(_yearController.text) ?? 2021,
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        seats: int.tryParse(_seatsController.text) ?? 5,
        gearbox: _selectedGearbox,
        fuelType: _selectedFuel,
        hasAC: _hasAC,
        isForRent: _isForRent,
        isForSale: _isForSale,
        rentPrice: double.tryParse(_rentPriceController.text),
        salePrice: double.tryParse(_salePriceController.text),
        securityDeposit: double.tryParse(_securityDepositController.text),
        vehicleImages: {
          'front': _imgFront!,
          'back': _imgBack!,
          'left': _imgLeft!,
          'right': _imgRight!,
          'interior': _imgInterior!,
        },
        documents: {
          'plate': _docPlate!,
          'registration': _docRegistration!,
          'insurance': _docInsurance!,
        },
      );
      if (mounted) {
        SnackbarUtils.showSuccess(context, "Véhicule enregistré !");
        context.pop();
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundCircles(size),
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Theme(
                  data: ThemeData(
                    colorScheme: const ColorScheme.light(
                      primary: kPrimaryColor,
                    ),
                    canvasColor: Colors.transparent,
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepContinue: _isLoading ? null : _nextStep,
                    onStepCancel: () => _currentStep > 0
                        ? setState(() => _currentStep -= 1)
                        : context.pop(),
                    elevation: 0,
                    controlsBuilder: _buildStepperControls,
                    steps: [
                      _stepBasicInfo(),
                      _stepTechDetails(),
                      _stepPhotos(),
                      _stepDocuments(),
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

  // --- ÉTAPES DU STEPPER ---

  Step _stepBasicInfo() {
    return Step(
      title: const Text("Base"),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          _buildModernTextField("Marque", Icons.car_repair, _brandController),
          const SizedBox(height: 15),
          _buildModernTextField(
            "Modèle",
            Icons.directions_car,
            _modelController,
          ),
          const SizedBox(height: 15),
          _buildModernTextField(
            "Année",
            Icons.calendar_today,
            _yearController,
            isNumber: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildIntentSelector(
                  "Location",
                  Icons.car_rental,
                  _isForRent,
                  () => setState(() => _isForRent = !_isForRent),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildIntentSelector(
                  "Vente",
                  Icons.sell,
                  _isForSale,
                  () => setState(() => _isForSale = !_isForSale),
                ),
              ),
            ],
          ),
          if (_isForRent) ...[
            const SizedBox(height: 15),
            _buildModernTextField(
              "Prix/Jour (FCFA)",
              Icons.payments,
              _rentPriceController,
              isNumber: true,
              isHighlight: true,
            ),
            const SizedBox(height: 15),

            // --- NOUVEAU CHAMP : CAUTION ---
            _buildModernTextField(
              "Caution exigée (FCFA)",
              Icons.shield_outlined,
              _securityDepositController,
              isNumber: true,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 10),
              child: Text(
                "Cette somme sera remboursée au locataire s'il n'y a aucun dommage.",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
          if (_isForSale) ...[
            const SizedBox(height: 15),
            _buildModernTextField(
              "Prix Vente (FCFA)",
              Icons.account_balance_wallet,
              _salePriceController,
              isNumber: true,
              isHighlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Step _stepTechDetails() {
    return Step(
      title: const Text("Détails"),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  "Places",
                  Icons.airline_seat_recline_normal,
                  _seatsController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              // Utilisation du nouveau sélecteur pour la boîte de vitesse
              Expanded(
                child: _buildDropdown(
                  "Boîte",
                  Icons.settings,
                  ["Manuelle", "Automatique", "Semi-automatique"],
                  _selectedGearbox,
                  (val) => setState(() => _selectedGearbox = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Utilisation pour le carburant
          _buildDropdown(
            "Carburant",
            Icons.local_gas_station,
            ["Essence", "Diesel", "Hybride", "Électrique"],
            _selectedFuel,
            (val) => setState(() => _selectedFuel = val),
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: const Text(
              "Climatisation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _hasAC,
            activeColor: kPrimaryColor,
            onChanged: (v) => setState(() => _hasAC = v),
          ),
          _buildModernTextField("Ville", Icons.location_city, _cityController),
          const SizedBox(height: 15),
          _buildModernTextField(
            "Adresse (Optionnel)",
            Icons.map,
            _addressController,
          ),
          const SizedBox(height: 15),
          _buildModernTextField(
            "Description",
            Icons.description,
            _descriptionController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Step _stepPhotos() {
    return Step(
      title: const Text("Photos"),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          _buildModernImageUploadBox(
            "Face Avant",
            _imgFront,
            () => _pickImage((f) => _imgFront = f),
          ),
          _buildModernImageUploadBox(
            "Arrière",
            _imgBack,
            () => _pickImage((f) => _imgBack = f),
          ),
          _buildModernImageUploadBox(
            "Côté Gauche",
            _imgLeft,
            () => _pickImage((f) => _imgLeft = f),
          ),
          _buildModernImageUploadBox(
            "Côté Droit",
            _imgRight,
            () => _pickImage((f) => _imgRight = f),
          ),
          _buildModernImageUploadBox(
            "Intérieur",
            _imgInterior,
            () => _pickImage((f) => _imgInterior = f),
          ),
        ],
      ),
    );
  }

  Step _stepDocuments() {
    return Step(
      title: const Text("Papiers"),
      isActive: _currentStep >= 3,
      content: Column(
        children: [
          _buildModernImageUploadBox(
            "Plaque d'immatriculation",
            _docPlate,
            () => _pickImage((f) => _docPlate = f),
          ),
          _buildModernImageUploadBox(
            "Carte Grise",
            _docRegistration,
            () => _pickImage((f) => _docRegistration = f),
          ),
          _buildModernImageUploadBox(
            "Assurance",
            _docInsurance,
            () => _pickImage((f) => _docInsurance = f),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    String currentValue,
    Function(String) onSelect,
  ) {
    return GestureDetector(
      onTap: () {
        // On ouvre un menu de sélection propre en bas de l'écran
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sélectionnez : $label",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  ...items
                      .map(
                        (item) => ListTile(
                          leading: Icon(icon, color: kPrimaryColor),
                          title: Text(item),
                          trailing: currentValue == item
                              ? const Icon(
                                  Icons.check_circle,
                                  color: kPrimaryColor,
                                )
                              : null,
                          onTap: () {
                            onSelect(item);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Icon(icon, color: kPrimaryColor, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  Text(
                    currentValue,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    bool isHighlight = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isHighlight
            ? Border.all(color: kPrimaryColor.withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber
            ? TextInputType.number
            : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildIntentSelector(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? kPrimaryColor : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernImageUploadBox(
    String title,
    File? file,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: file != null ? Colors.green : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.camera_alt,
              color: file != null ? Colors.green : kPrimaryColor,
            ),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (file != null) const Icon(Icons.edit, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperControls(context, details) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _currentStep == 3 ? "Soumettre" : "Suivant",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (_currentStep > 0) ...[
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: const BorderSide(color: kPrimaryColor),
                ),
                child: const Text(
                  "Retour",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kPrimaryColor, dPrimaryColor]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            const Text(
              "Ajouter un véhicule",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) {
    return Stack(
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
      ],
    );
  }
}
