import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  // Fichiers d'images sélectionnés
  File? _imgFront, _imgBack, _imgSides, _imgInterior;
  File? _docPlate, _docRegistration, _docInsurance;

  // Intentions (Location / Vente)
  bool _isForRent = true;
  bool _isForSale = false;

  final ImagePicker _picker = ImagePicker();

  // Fonction pour ouvrir la galerie
  Future<void> _pickImage(Function(File) onImagePicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        onImagePicked(File(image.path));
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_brandController.text.isEmpty || _modelController.text.isEmpty || _yearController.text.isEmpty) {
        SnackbarUtils.showWarning(context, "Veuillez remplir toutes les informations.");
        return;
      }
    } else if (_currentStep == 1) {
      if (_imgFront == null || _imgBack == null || _imgSides == null || _imgInterior == null) {
        SnackbarUtils.showWarning(context, "Veuillez ajouter les 4 photos du véhicule.");
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
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  Future<void> _submitVehicle() async {
    if (_docPlate == null || _docRegistration == null || _docInsurance == null) {
      SnackbarUtils.showWarning(context, "Veuillez fournir tous les documents administratifs.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vehicleImages = [_imgFront!, _imgBack!, _imgSides!, _imgInterior!];

      await Provider.of<VehicleProvider>(context, listen: false).addVehicle(
        brand: _brandController.text.trim(),
        modelName: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()) ?? 2020,
        isForRent: _isForRent,
        isForSale: _isForSale,
        vehicleImages: vehicleImages,
        registrationPlate: _docPlate!,
        registrationDocument: _docRegistration!,
        insuranceCertificate: _docInsurance!,
      );

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Véhicule soumis avec succès ! En attente de validation.");
        context.pop(); // Retour à la liste des véhicules
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, "Erreur lors de l'ajout.");
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
          // ... (Garde tes cercles décoratifs et le Header fixe ici comme dans ton code précédent) ...
          Positioned(
            left: -size.width * 0.3, bottom: size.height * 0.4,
            child: Container(width: size.width * 0.6, height: size.width * 0.6, decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle)),
          ),
          
          Column(
            children: [
              // HEADER DÉGRADÉ FIXE
              Container(
                height: 120, width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPrimaryColor, dPrimaryColor]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.pop()),
                        const SizedBox(width: 10),
                        const Text("Ajouter un véhicule", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Theme(
                  data: ThemeData(colorScheme: const ColorScheme.light(primary: kPrimaryColor), canvasColor: Colors.transparent),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepContinue: _nextStep,
                    onStepCancel: _cancelStep,
                    elevation: 0,
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : details.onStepContinue,
                                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                child: _isLoading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_currentStep == 2 ? "Soumettre" : "Suivant", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            if (_currentStep > 0 && !_isLoading) ...[
                              const SizedBox(width: 15),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: kPrimaryColor, width: 2)),
                                  child: const Text("Retour", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                    steps: [
                      // ÉTAPE 1 : INFOS
                      Step(
                        title: const Text("Infos"),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                        content: Column(
                          children: [
                            _buildModernTextField("Marque (ex: Toyota)", Icons.car_repair, _brandController),
                            const SizedBox(height: 15),
                            _buildModernTextField("Modèle (ex: Corolla)", Icons.directions_car, _modelController),
                            const SizedBox(height: 15),
                            _buildModernTextField("Année (ex: 2021)", Icons.calendar_today, _yearController, isNumber: true),
                            const SizedBox(height: 20),
                            SwitchListTile(
                              title: const Text("Mettre en Location", style: TextStyle(fontWeight: FontWeight.bold)),
                              activeColor: kPrimaryColor,
                              value: _isForRent,
                              onChanged: (val) => setState(() => _isForRent = val),
                            ),
                            SwitchListTile(
                              title: const Text("Mettre en Vente", style: TextStyle(fontWeight: FontWeight.bold)),
                              activeColor: Colors.orange.shade600,
                              value: _isForSale,
                              onChanged: (val) => setState(() => _isForSale = val),
                            ),
                          ],
                        ),
                      ),
                      
                      // ÉTAPE 2 : PHOTOS
                      Step(
                        title: const Text("Photos"),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Appuyez sur les blocs pour ajouter vos photos.", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            _buildModernImageUploadBox("Face Avant", _imgFront, () => _pickImage((f) => _imgFront = f)),
                            _buildModernImageUploadBox("Arrière", _imgBack, () => _pickImage((f) => _imgBack = f)),
                            _buildModernImageUploadBox("Côtés (Gauche/Droit)", _imgSides, () => _pickImage((f) => _imgSides = f)),
                            _buildModernImageUploadBox("Intérieur", _imgInterior, () => _pickImage((f) => _imgInterior = f)),
                          ],
                        ),
                      ),

                      // ÉTAPE 3 : PAPIERS
                      Step(
                        title: const Text("Papiers"),
                        isActive: _currentStep >= 2,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Documents obligatoires pour la validation.", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            _buildModernImageUploadBox("Plaque d'immatriculation", _docPlate, () => _pickImage((f) => _docPlate = f)),
                            _buildModernImageUploadBox("Carte Grise", _docRegistration, () => _pickImage((f) => _docRegistration = f)),
                            _buildModernImageUploadBox("Attestation d'assurance", _docInsurance, () => _pickImage((f) => _docInsurance = f)),
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

  Widget _buildModernTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, color: kPrimaryColor, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  // WIDGET D'UPLOAD MODIFIÉ POUR CLIQUER ET VOIR L'ÉTAT
  Widget _buildModernImageUploadBox(String title, File? file, VoidCallback onTap) {
    bool hasFile = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasFile ? kPrimaryColor : Colors.transparent, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                color: hasFile ? kPrimaryColor : lPrimaryColor, 
                borderRadius: BorderRadius.circular(12),
                // Si l'image est sélectionnée, on l'affiche en miniature
                image: hasFile ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
              ),
              child: hasFile ? null : const Icon(Icons.camera_alt, color: kPrimaryColor, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: hasFile ? kPrimaryColor : Colors.black))),
            Icon(hasFile ? Icons.check_circle : Icons.add_circle_outline, color: hasFile ? kPrimaryColor : Colors.grey),
          ],
        ),
      ),
    );
  }
}