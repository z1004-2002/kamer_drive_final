import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // --- CERCLES DÉCORATIFS ---
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
              // 1. HEADER
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
                          "Confidentialité",
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

              // 2. TEXTE DE LA POLITIQUE
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Politique de Confidentialité",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Dernière mise à jour : Mars 2026",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 25),

                      _buildPolicySection(
                        icon: Icons.data_usage,
                        title: "1. Données collectées",
                        content:
                            "Pour utiliser Kamer Drive, nous collectons des informations personnelles telles que votre nom, adresse email, numéro de téléphone, et adresse physique. Dans le cadre des locations, nous recueillons également vos documents d'identité (CNI, Passeport, Permis de conduire) pour vérifier votre profil et assurer la sécurité des transactions.",
                      ),

                      _buildPolicySection(
                        icon: Icons.handshake_outlined,
                        title: "2. Utilisation de vos données",
                        content:
                            "Vos données sont utilisées exclusivement pour :\n• Valider votre identité et créer votre profil.\n• Faciliter la mise en relation entre loueurs et locataires.\n• Gérer vos paiements et réservations.\n• Améliorer nos services et assurer un support client efficace.",
                      ),

                      _buildPolicySection(
                        icon: Icons.share_outlined,
                        title: "3. Partage des informations",
                        content:
                            "Nous ne vendons jamais vos données personnelles à des tiers. Vos informations de base (nom, photo, numéro de téléphone) ne sont partagées avec d'autres utilisateurs que lorsqu'une transaction (location/vente) est confirmée entre vous. Vos documents d'identité sont strictement confidentiels et ne sont vus que par nos administrateurs.",
                      ),

                      _buildPolicySection(
                        icon: Icons.security,
                        title: "4. Sécurité",
                        content:
                            "Nous mettons en œuvre des mesures de sécurité avancées (chiffrement, serveurs sécurisés) pour protéger vos données contre tout accès non autorisé, altération ou destruction. Cependant, aucune méthode de transmission sur Internet n'est sûre à 100%.",
                      ),

                      _buildPolicySection(
                        icon: Icons.manage_accounts_outlined,
                        title: "5. Vos droits",
                        content:
                            "Vous avez le droit de consulter, modifier ou supprimer vos informations personnelles à tout moment depuis l'application. Si vous souhaitez supprimer définitivement votre compte et vos données, vous pouvez en faire la demande via notre service support.",
                      ),

                      const SizedBox(height: 40),
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

  // --- WIDGET HELPER POUR CHAQUE SECTION ---
  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
