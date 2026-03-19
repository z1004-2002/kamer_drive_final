import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- NOUVEL IMPORT NÉCESSAIRE
import 'package:firebase_auth/firebase_auth.dart'; // <--- NOUVEL IMPORT NÉCESSAIRE
import 'package:image_picker/image_picker.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // --- NOUVEAUX ÉTATS POUR LE VÉHICULE ---
  bool _ownsVehicle = false;
  bool _hasRegisteredVehicles =
      false; // Permet de savoir si on doit bloquer le bouton

  File? _newAvatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).currentUser;
    if (currentUser != null) {
      _firstNameController.text = currentUser.firstName;
      _lastNameController.text = currentUser.lastName;
      _phoneController.text = currentUser.phone;
      _addressController.text = currentUser.address;
      // On récupère sa valeur actuelle
      _ownsVehicle = currentUser.ownsVehicle;
    }

    // On lance la vérification en arrière-plan
    _checkIfUserHasVehicles();
  }

  @override
  void dispose() {
    for (var controller in [
      _firstNameController,
      _lastNameController,
      _phoneController,
      _addressController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- VÉRIFICATION FIRESTORE ---
  Future<void> _checkIfUserHasVehicles() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // On cherche juste s'il y a au moins 1 véhicule à son nom (limit(1) est très rapide)
      final snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        setState(() {
          _hasRegisteredVehicles = true;
          _ownsVehicle = true; // On force la valeur à true par sécurité
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification des véhicules : $e");
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) setState(() => _newAvatarFile = File(image.path));
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      SnackbarUtils.showWarning(
        context,
        "Le prénom et le nom sont obligatoires.",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProfileProvider>(context, listen: false).updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        ownsVehicle: _ownsVehicle, // <--- On envoie la valeur
        newAvatarFile: _newAvatarFile,
      );

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Profil mis à jour avec succès !");
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          "Erreur lors de la mise à jour : ${e.toString().replaceAll('Exception: ', '')}",
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final currentUser = context.watch<ProfileProvider>().currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: _buildNotabeSaveButton(),
      body: Stack(
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

          Column(
            children: [
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
                          "Infos Personnelles",
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

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: _newAvatarFile != null
                                  ? FileImage(_newAvatarFile!) as ImageProvider
                                  : ((currentUser?.avatarUrl ?? '').isNotEmpty
                                        ? NetworkImage(currentUser!.avatarUrl)
                                        : null),
                              child:
                                  (_newAvatarFile == null &&
                                      (currentUser?.avatarUrl ?? '').isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Appuyez pour modifier la photo",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                      const SizedBox(height: 40),

                      _buildModernTextField(
                        "Prénom",
                        Icons.person,
                        _firstNameController,
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        "Nom",
                        Icons.person_outline,
                        _lastNameController,
                      ),
                      const SizedBox(height: 15),

                      _buildReadOnlyTextField(
                        currentUser?.email ?? "email@exemple.com",
                        Icons.email,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, top: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "L'adresse email ne peut pas être modifiée ici.",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      _buildModernTextField(
                        "Téléphone",
                        Icons.phone,
                        _phoneController,
                        isPhone: true,
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        "Adresse physique",
                        Icons.location_on,
                        _addressController,
                      ),

                      const SizedBox(height: 25),

                      // --- NOUVEAU WIDGET : LE SWITCH PROPRIÉTAIRE ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _hasRegisteredVehicles
                                ? Colors.orange.shade200
                                : Colors.transparent,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            "Je possède un véhicule",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: _hasRegisteredVehicles
                              ? const Text(
                                  "Option verrouillée : vous avez déjà enregistré des véhicules.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                  ),
                                )
                              : const Text(
                                  "Activez si vous comptez proposer des véhicules.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                          value: _ownsVehicle,
                          activeColor: kPrimaryColor,
                          // Si _hasRegisteredVehicles est vrai, onChanged est null, ce qui désactive le switch
                          onChanged: _hasRegisteredVehicles
                              ? null
                              : (value) {
                                  setState(() {
                                    _ownsVehicle = value;
                                  });
                                },
                        ),
                      ),

                      const SizedBox(height: 30),
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

  Widget _buildNotabeSaveButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
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
                    "Enregistrer les modifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPhone = false,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField(String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: value,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
