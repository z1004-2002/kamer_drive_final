import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../../../models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class EditVehicleScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // --- CONTRÔLEURS ---
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _rentPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _seatsController;
  late TextEditingController _securityDepositController;
  late TextEditingController _rentPriceWithDriverController;

  // --- ÉTATS ---
  late bool _isForRent;
  late bool _isForSale;
  late bool _hasAC;
  late String _selectedGearbox;
  late String _selectedFuel;
  late bool _withDriverOption;

  // --- NOUVELLES IMAGES (Si modifiées) ---
  final ImagePicker _picker = ImagePicker();
  File? _newImgFront, _newImgBack, _newImgLeft, _newImgRight, _newImgInterior;
  File? _newDocPlate, _newDocRegistration, _newDocInsurance;

  @override
  void initState() {
    super.initState();
    // 1. On pré-remplit tous les contrôleurs avec les données du véhicule existant
    _brandController = TextEditingController(text: widget.vehicle.brand);
    _modelController = TextEditingController(text: widget.vehicle.modelName);
    _yearController = TextEditingController(
      text: widget.vehicle.year.toString(),
    );
    _rentPriceController = TextEditingController(
      text: widget.vehicle.rentPricePerDay?.toInt().toString() ?? "",
    );
    _salePriceController = TextEditingController(
      text: widget.vehicle.salePrice?.toInt().toString() ?? "",
    );
    _cityController = TextEditingController(text: widget.vehicle.city);
    _addressController = TextEditingController(text: widget.vehicle.address);
    _descriptionController = TextEditingController(
      text: widget.vehicle.description,
    );
    _seatsController = TextEditingController(
      text: widget.vehicle.seats.toString(),
    );
    _securityDepositController = TextEditingController(
      text: widget.vehicle.securityDeposit?.toInt().toString() ?? "",
    );
    _rentPriceWithDriverController = TextEditingController(
      text: widget.vehicle.rentPriceWithDriver?.toInt().toString() ?? "",
    );

    _isForRent = widget.vehicle.isForRent;
    _isForSale = widget.vehicle.isForSale;
    _hasAC = widget.vehicle.hasAC;
    _selectedGearbox = widget.vehicle.gearbox;
    _selectedFuel = widget.vehicle.fuelType;
    _withDriverOption = widget.vehicle.withDriverOption ?? false;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _rentPriceController.dispose();
    _salePriceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();
    _securityDepositController.dispose();
    _rentPriceWithDriverController.dispose();
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
    // Validations allégées pour l'édition
    if (_currentStep == 0 &&
        (_brandController.text.isEmpty || _modelController.text.isEmpty)) {
      return SnackbarUtils.showWarning(
        context,
        "Marque et modèle obligatoires.",
      );
    } else if (_currentStep == 1 && _cityController.text.isEmpty) {
      return SnackbarUtils.showWarning(context, "La ville est obligatoire.");
    }

    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _saveChanges();
    }
  }

  Future<void> _saveChanges() async {
    if (!_isForRent && !_isForSale) {
      return SnackbarUtils.showWarning(
        context,
        "Le véhicule doit être au moins à louer ou à vendre.",
      );
    }

    setState(() => _isLoading = true);

    try {
      // 1. Préparation des données textuelles
      Map<String, dynamic> updates = {
        'brand': _brandController.text.trim(),
        'modelName': _modelController.text.trim(),
        'year': int.tryParse(_yearController.text) ?? widget.vehicle.year,
        'description': _descriptionController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
        'seats': int.tryParse(_seatsController.text) ?? widget.vehicle.seats,
        'gearbox': _selectedGearbox,
        'fuelType': _selectedFuel,
        'hasAC': _hasAC,
        'isForRent': _isForRent,
        'isForSale': _isForSale,
        'withDriverOption': _withDriverOption,
      };

      if (_isForRent) {
        updates['rentPricePerDay'] =
            double.tryParse(_rentPriceController.text) ??
            widget.vehicle.rentPricePerDay;
        updates['securityDeposit'] =
            double.tryParse(_securityDepositController.text) ??
            widget.vehicle.securityDeposit;
        updates['rentPriceWithDriver'] = _withDriverOption
            ? (double.tryParse(_rentPriceWithDriverController.text) ??
                  widget.vehicle.rentPriceWithDriver)
            : null;
      }

      if (_isForSale) {
        updates['salePrice'] =
            double.tryParse(_salePriceController.text) ??
            widget.vehicle.salePrice;
      }

      // 2. Préparation des NOUVEAUX fichiers (S'il y en a)
      Map<String, File> newImages = {};
      if (_newImgFront != null) newImages['front'] = _newImgFront!;
      if (_newImgBack != null) newImages['back'] = _newImgBack!;
      if (_newImgLeft != null) newImages['left'] = _newImgLeft!;
      if (_newImgRight != null) newImages['right'] = _newImgRight!;
      if (_newImgInterior != null) newImages['interior'] = _newImgInterior!;

      Map<String, File> newDocs = {};
      if (_newDocPlate != null) newDocs['plate'] = _newDocPlate!;
      if (_newDocRegistration != null)
        newDocs['registration'] = _newDocRegistration!;
      if (_newDocInsurance != null) newDocs['insurance'] = _newDocInsurance!;

      // 3. Appel au Provider
      await context.read<VehicleProvider>().updateVehicleInfo(
        widget.vehicle.id,
        updates,
        newImages: newImages.isNotEmpty ? newImages : null,
        newDocs: newDocs.isNotEmpty ? newDocs : null,
      );

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Véhicule mis à jour avec succès !");
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll("Exception: ", "");
        SnackbarUtils.showError(context, errorMsg);
      }
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
            SwitchListTile(
              title: const Text(
                "Proposer l'option Chauffeur",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "Le locataire pourra choisir s'il veut un chauffeur.",
              ),
              value: _withDriverOption,
              activeColor: kPrimaryColor,
              onChanged: (v) => setState(() => _withDriverOption = v),
            ),
            if (_withDriverOption) ...[
              const SizedBox(height: 10),
              _buildModernTextField(
                "Prix AVEC chauffeur/Jour (FCFA)",
                Icons.person_pin,
                _rentPriceWithDriverController,
                isNumber: true,
                isHighlight: true,
              ),
            ],
            const SizedBox(height: 15),
            _buildModernTextField(
              "Caution exigée (FCFA)",
              Icons.shield_outlined,
              _securityDepositController,
              isNumber: true,
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
    // Helper pour récupérer l'URL existante si elle existe (On suppose l'ordre classique)
    String? getOldUrl(int index) => widget.vehicle.images.length > index
        ? widget.vehicle.images[index]
        : null;

    return Step(
      title: const Text("Photos"),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          _buildModernImageEditBox(
            "Face Avant",
            _newImgFront,
            getOldUrl(0),
            () => _pickImage((f) => _newImgFront = f),
          ),
          _buildModernImageEditBox(
            "Arrière",
            _newImgBack,
            getOldUrl(1),
            () => _pickImage((f) => _newImgBack = f),
          ),
          _buildModernImageEditBox(
            "Côté Gauche",
            _newImgLeft,
            getOldUrl(2),
            () => _pickImage((f) => _newImgLeft = f),
          ),
          _buildModernImageEditBox(
            "Côté Droit",
            _newImgRight,
            getOldUrl(3),
            () => _pickImage((f) => _newImgRight = f),
          ),
          _buildModernImageEditBox(
            "Intérieur",
            _newImgInterior,
            getOldUrl(4),
            () => _pickImage((f) => _newImgInterior = f),
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
          _buildModernImageEditBox(
            "Plaque d'immatriculation",
            _newDocPlate,
            widget.vehicle.registrationPlateUrl,
            () => _pickImage((f) => _newDocPlate = f),
          ),
          _buildModernImageEditBox(
            "Carte Grise",
            _newDocRegistration,
            widget.vehicle.registrationDocumentUrl,
            () => _pickImage((f) => _newDocRegistration = f),
          ),
          _buildModernImageEditBox(
            "Assurance",
            _newDocInsurance,
            widget.vehicle.insuranceCertificateUrl,
            () => _pickImage((f) => _newDocInsurance = f),
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
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

  // NOUVEAU : Widget spécial Édition d'image
  Widget _buildModernImageEditBox(
    String title,
    File? newFile,
    String? oldUrl,
    VoidCallback onTap,
  ) {
    bool hasOld = oldUrl != null && oldUrl.isNotEmpty;
    bool hasNew = newFile != null;

    Color borderColor = hasNew
        ? Colors.green
        : (hasOld ? kPrimaryColor.withOpacity(0.5) : Colors.transparent);
    IconData leadingIcon = hasNew
        ? Icons.check_circle
        : (hasOld ? Icons.image : Icons.camera_alt);
    Color iconColor = hasNew
        ? Colors.green
        : (hasOld ? kPrimaryColor : Colors.grey);
    String subtitle = hasNew
        ? "Nouvelle photo sélectionnée"
        : (hasOld ? "Photo actuelle conservée" : "Aucune photo");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: iconColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.black87),
            ),
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
          if (_currentStep > 0) ...[
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
            const SizedBox(width: 10),
          ],
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 3 ? "Sauvegarder" : "Suivant",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
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
              "Modifier le véhicule",
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
