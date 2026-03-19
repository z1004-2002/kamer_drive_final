import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../providers/profile_provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // 'cni' ou 'passport'
  String _selectedIdType = 'cni';

  // Fichiers locaux
  File? _idFront;
  File? _idBack;
  File? _passport;
  File? _licenseFront;
  File? _licenseBack;

  @override
  void initState() {
    super.initState();
    // Logique de détection au démarrage
    final docs =
        Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).currentUser?.idDocuments ??
        {};
    if (docs.containsKey('passport') &&
        docs['passport'].toString().isNotEmpty) {
      _selectedIdType = 'passport';
    } else {
      _selectedIdType = 'cni';
    }
  }

  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) setState(() => onSelected(File(image.path)));
  }

  Future<void> _submitDocuments() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).uploadIdentityDocuments(
        idFront: _selectedIdType == 'cni' ? _idFront : null,
        idBack: _selectedIdType == 'cni' ? _idBack : null,
        passport: _selectedIdType == 'passport' ? _passport : null,
        licenseFront: _licenseFront,
        licenseBack: _licenseBack,
      );
      if (mounted) {
        SnackbarUtils.showSuccess(context, "Documents enregistrés !");
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
    final docs =
        context.watch<ProfileProvider>().currentUser?.idDocuments ?? {};
    bool hasChanges =
        _idFront != null ||
        _idBack != null ||
        _passport != null ||
        _licenseFront != null ||
        _licenseBack != null;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // BOUTON COMME DANS EDIT PROFILE
      bottomNavigationBar: _buildSaveButton(hasChanges),
      body: Stack(
        children: [
          // Cercles de fond
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
              // Header
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SÉLECTEUR DE TYPE D'IDENTITÉ
                      const Text(
                        "Type de pièce d'identité",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildIdTypeSelector(),

                      const SizedBox(height: 25),

                      // AFFICHAGE CONDITIONNEL
                      if (_selectedIdType == 'cni') ...[
                        _buildDocumentCard(
                          "CNI - Recto",
                          _idFront,
                          docs['id_front'],
                          () => _pickImage((f) => _idFront = f),
                        ),
                        _buildDocumentCard(
                          "CNI - Verso",
                          _idBack,
                          docs['id_back'],
                          () => _pickImage((f) => _idBack = f),
                        ),
                      ] else ...[
                        _buildDocumentCard(
                          "Passeport (Page info)",
                          _passport,
                          docs['passport'],
                          () => _pickImage((f) => _passport = f),
                        ),
                      ],

                      const Divider(height: 40, thickness: 1),

                      const Text(
                        "Permis de conduire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildDocumentCard(
                        "Permis - Recto",
                        _licenseFront,
                        docs['license_front'],
                        () => _pickImage((f) => _licenseFront = f),
                      ),
                      _buildDocumentCard(
                        "Permis - Verso",
                        _licenseBack,
                        docs['license_back'],
                        () => _pickImage((f) => _licenseBack = f),
                      ),

                      const SizedBox(height: 20),
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

  // --- WIDGET : LE SÉLECTEUR (Toggle) ---
  Widget _buildIdTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSelectOption("cni", "Carte d'identité"),
          _buildSelectOption("passport", "Passeport"),
        ],
      ),
    );
  }

  Widget _buildSelectOption(String type, String label) {
    bool isSelected = _selectedIdType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIdType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET : LE BOUTON FIXE ---
  Widget _buildSaveButton(bool active) {
    return Container(
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
            onPressed: (active && !_isLoading) ? _submitDocuments : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Enregistrer les documents",
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

  // Widget Header et Card (Gardés de la version précédente pour la cohérence)
  Widget _buildHeader() {
    return Container(
      height: 110,
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
              "Mes Documents",
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

  Widget _buildDocumentCard(
    String title,
    File? local,
    String? url,
    VoidCallback onTap,
  ) {
    bool hasFile = local != null || (url != null && url.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 1.6,
              child: Container(
                decoration: BoxDecoration(
                  color: hasFile ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: hasFile ? kPrimaryColor : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: local != null
                      ? Image.file(local, fit: BoxFit.cover)
                      : (url != null
                            ? Image.network(url, fit: BoxFit.cover)
                            : const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
