import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;

  // --- CONTRÔLEURS ---
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _salePriceController = TextEditingController();

  // --- ÉTATS CONDITIONNELS ---
  bool _isForRent = false;
  bool _isForSale = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _rentPriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  // --- NAVIGATION DU STEPPER ---
  void _nextStep() {
    // Validation de l'étape 1 avant de passer à la suite
    if (_currentStep == 0) {
      if (_brandController.text.isEmpty ||
          _modelController.text.isEmpty ||
          _yearController.text.isEmpty) {
        SnackbarUtils.showWarning(
          context,
          "Veuillez remplir les informations du véhicule.",
        );
        return;
      }

      // LA MODIFICATION EST ICI : On a retiré l'obligation de choisir Location ou Vente.
      // On vérifie uniquement les prix SI l'option est cochée.

      if (_isForRent && _rentPriceController.text.isEmpty) {
        SnackbarUtils.showWarning(
          context,
          "Veuillez indiquer le prix de location.",
        );
        return;
      }
      if (_isForSale && _salePriceController.text.isEmpty) {
        SnackbarUtils.showWarning(
          context,
          "Veuillez indiquer le prix de vente.",
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _submitVehicle();
    }
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submitVehicle() async {
    SnackbarUtils.showSuccess(
      context,
      "Véhicule soumis ! En attente de validation.",
    );
    context.pop(); // Retour à la liste
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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

          // --- CONTENU PRINCIPAL ---
          Column(
            children: [
              // 1. HEADER FIXE
              Container(
                height: 120,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                ),
              ),

              // 2. LE STEPPER (Formulaire)
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
                    onStepContinue: _nextStep,
                    onStepCancel: _cancelStep,
                    elevation: 0,

                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 40),
                        child: Row(
                          children: [
                            if (_currentStep > 0) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: const BorderSide(
                                      color: kPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Text(
                                    "Retour",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  _currentStep == 2 ? "Soumettre" : "Suivant",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },

                    steps: [
                      // --- ÉTAPE 1 : INFOS ET PRIX ---
                      Step(
                        title: const Text("Infos"),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildModernTextField(
                              "Marque (ex: Toyota)",
                              Icons.car_repair,
                              _brandController,
                            ),
                            const SizedBox(height: 15),
                            _buildModernTextField(
                              "Modèle (ex: Corolla)",
                              Icons.directions_car,
                              _modelController,
                            ),
                            const SizedBox(height: 15),
                            _buildModernTextField(
                              "Année (ex: 2021)",
                              Icons.calendar_today,
                              _yearController,
                              isNumber: true,
                            ),

                            const SizedBox(height: 30),
                            const Text(
                              "Que souhaitez-vous faire ? (Optionnel)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // BOUTONS DE SÉLECTION (Location / Vente)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildIntentSelector(
                                    "Location",
                                    Icons.car_rental,
                                    _isForRent,
                                    () {
                                      setState(() => _isForRent = !_isForRent);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildIntentSelector(
                                    "Vente",
                                    Icons.sell_outlined,
                                    _isForSale,
                                    () {
                                      setState(() => _isForSale = !_isForSale);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // CHAMPS DE PRIX CONDITIONNELS (Avec animation)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Column(
                                children: [
                                  if (_isForRent) ...[
                                    const SizedBox(height: 20),
                                    _buildModernTextField(
                                      "Prix par jour (FCFA)",
                                      Icons.payments_outlined,
                                      _rentPriceController,
                                      isNumber: true,
                                      isHighlight: true,
                                    ),
                                  ],
                                  if (_isForSale) ...[
                                    const SizedBox(height: 20),
                                    _buildModernTextField(
                                      "Prix de vente total (FCFA)",
                                      Icons.account_balance_wallet_outlined,
                                      _salePriceController,
                                      isNumber: true,
                                      isHighlight: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- ÉTAPE 2 : PHOTOS ---
                      Step(
                        title: const Text("Photos"),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ajoutez 4 photos extérieures et l'intérieur.",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            _buildModernImageUploadBox("Face Avant"),
                            _buildModernImageUploadBox("Arrière"),
                            _buildModernImageUploadBox(
                              "Côtés (Gauche & Droit)",
                            ),
                            _buildModernImageUploadBox("Intérieur"),
                          ],
                        ),
                      ),

                      // --- ÉTAPE 3 : PAPIERS ---
                      Step(
                        title: const Text("Papiers"),
                        isActive: _currentStep >= 2,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Documents obligatoires pour la validation.",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            _buildModernImageUploadBox(
                              "Plaque d'immatriculation",
                            ),
                            _buildModernImageUploadBox("Carte Grise"),
                            _buildModernImageUploadBox(
                              "Attestation d'assurance",
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

  // --- WIDGETS DESIGN SYSTEM ---

  Widget _buildModernTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    bool isHighlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isHighlight
            ? Border.all(color: kPrimaryColor.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(
            icon,
            color: isHighlight ? kPrimaryColor : Colors.grey.shade600,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? kPrimaryColor : Colors.grey.shade600,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? kPrimaryColor : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernImageUploadBox(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
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
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: lPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.camera_alt, color: kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const Icon(Icons.add_circle_outline, color: Colors.grey),
        ],
      ),
    );
  }
}
