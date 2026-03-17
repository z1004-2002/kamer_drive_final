import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final bool hasVehicles = false; // Simulation d'une liste vide

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // --- CERCLES DÉCORATIFS EN FOND ---
          Positioned(
            left: -size.width * 0.3, bottom: size.height * 0.4,
            child: Container(width: size.width * 0.6, height: size.width * 0.6, decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -size.width * 0.2, right: -size.width * 0.4,
            child: Container(width: size.width * 0.7, height: size.width * 0.7, decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle)),
          ),

          // --- CONTENU PRINCIPAL ---
          Column(
            children: [
              // 1. HEADER DÉGRADÉ FIXE
              Container(
                height: 120, // Hauteur fixe adaptée
                width: double.infinity,
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Mes Véhicules",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. CONTENU SCROLLABLE
              Expanded(
                child: hasVehicles ? _buildVehicleList() : _buildEmptyState(context),
              ),
            ],
          ),
        ],
      ),
      
      // BOUTON FLOTTANT D'AJOUT
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_vehicle'),
        backgroundColor: kPrimaryColor,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter un véhicule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- ÉCRAN VIDE (Design Modernisé) ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(color: lPrimaryColor, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.directions_car_outlined, size: 40, color: kPrimaryColor),
              ),
              const SizedBox(height: 20),
              const Text("Aucun véhicule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Text(
                "Ajoutez votre véhicule pour commencer à le louer ou le vendre sur la plateforme.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return const Center(child: Text("Liste des véhicules ici"));
  }
}