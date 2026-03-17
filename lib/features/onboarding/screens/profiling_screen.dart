import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import 'package:kamer_drive_final/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import '../../auth/providers/auth_provider.dart';

class ProfilingScreen extends StatefulWidget {
  const ProfilingScreen({super.key});

  @override
  State<ProfilingScreen> createState() => _ProfilingScreenState();
}

class _ProfilingScreenState extends State<ProfilingScreen> {
  // Les intentions choisies par l'utilisateur
  final List<String> _selectedIntents = [];
  
  // Possède-t-il un véhicule ?
  bool _ownsVehicle = false;
  bool _isLoading = false;

  // Liste des intentions issues du cahier des charges
  final List<Map<String, dynamic>> _intents = [
    {"id": "rent_car", "title": "Louer un véhicule", "subtitle": "Trouvez la voiture idéale", "icon": Icons.key},
    {"id": "buy_car", "title": "Acheter une voiture", "subtitle": "Devenez propriétaire", "icon": Icons.shopping_cart},
    {"id": "put_for_rent", "title": "Mettre en location", "subtitle": "Rentabilisez votre voiture", "icon": Icons.car_rental},
    {"id": "sell_car", "title": "Vendre une voiture", "subtitle": "Trouvez un acheteur", "icon": Icons.sell},
    // {"id": "find_ride", "title": "Trouver un trajet", "subtitle": "Voyagez à moindre coût", "icon": Icons.hail},
    // {"id": "offer_ride", "title": "Proposer un trajet", "subtitle": "Partagez vos frais", "icon": Icons.directions_car},
  ];

  void _toggleIntent(String id) {
    setState(() {
      if (_selectedIntents.contains(id)) {
        _selectedIntents.remove(id);
      } else {
        _selectedIntents.add(id);
      }
    });
  }

  Future<void> _submitProfile() async {
    if (_selectedIntents.isEmpty) {
      SnackbarUtils.showWarning(context, "Veuillez sélectionner au moins une intention.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Appel au AuthProvider pour mettre à jour Firestore
      
      await Provider.of<AuthProvider>(context, listen: false).completeProfiling(
        intents: _selectedIntents,
        ownsVehicle: _ownsVehicle,
      );
      
      
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Profil configuré avec succès !");
        
        // Redirection vers l'accueil (ou l'ajout de véhicule selon le cas)
        // context.go('/home');
        print("Aller vers l'accueil");
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, "Une erreur est survenue.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor, // Le même fond que l'accueil
      body: Stack(
        children: [
          // --- CERCLES DÉCORATIFS (Comme à l'accueil) ---
          Positioned(
            left: -size.width * 0.3,
            bottom: size.height * 0.4,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            right: -size.width * 0.4,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
            ),
          ),

          // --- CONTENU PRINCIPAL ---
          Column(
            children: [
              // 1. HEADER DÉGRADÉ (Comme SearchScreen / HomeScreen)
              Container(
                height: size.height * 0.15,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, dPrimaryColor], // Couleurs de l'en-tête
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Votre Profil",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. LISTE SCROLLABLE DES OPTIONS
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      "Qu'est-ce qui vous amène sur KamerDrive ?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Sélectionnez ce que vous souhaitez faire (plusieurs choix possibles).",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 25),

                    // LISTE AVEC CHECKBOX
                    ..._intents.map((intent) {
                      final isSelected = _selectedIntents.contains(intent["id"]);
                      return GestureDetector(
                        onTap: () => _toggleIntent(intent["id"]),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? kPrimaryColor : Colors.transparent,
                              width: 1.5,
                            ),
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
                              // Icône stylisée
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isSelected ? kPrimaryColor : lPrimaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  intent["icon"],
                                  color: isSelected ? Colors.white : kPrimaryColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // Textes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      intent["title"],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      intent["subtitle"],
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Checkbox
                              Checkbox(
                                value: isSelected,
                                activeColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (value) => _toggleIntent(intent["id"]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(),
                    ),

                    // 3. TOGGLE BOUTON (VÉHICULE)
                    const Text(
                      "Déclaration de véhicule",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    
                    Container(
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
                              color: _ownsVehicle ? kPrimaryColor : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: _ownsVehicle ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Je possède un véhicule",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "Nécessaire pour vendre ou louer",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Le Switch (Toggle)
                          Switch(
                            value: _ownsVehicle,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() {
                                _ownsVehicle = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // 4. BOUTON FIXE EN BAS (Continuer)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Continuer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}