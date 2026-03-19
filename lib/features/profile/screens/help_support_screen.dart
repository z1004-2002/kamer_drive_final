import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});
  Future<void> _launchUrl(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Impossible d'ouvrir ce lien. Vérifiez que l'application correspondante est installée.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erreur url_launcher : $e");
    }
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

          Column(
            children: [
              // 1. HEADER DÉGRADÉ FIXE
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
                          "Aide & Support",
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

              // 2. CONTENU SCROLLABLE
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SECTION CONTACT ---
                      const Text(
                        "Comment pouvons-nous vous aider ?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Notre équipe est disponible 7j/7 pour répondre à toutes vos questions.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      // Cartes de contact rapides
                      Row(
                        children: [
                          _buildContactCard(
                            context: context,
                            icon: Icons.chat_bubble_outline,
                            title: "WhatsApp",
                            color: Colors.green,
                            onTap: () {
                              // Remplace par ton vrai numéro (avec le code pays, sans le +)
                              final whatsappUrl =
                                  "https://wa.me/237600000000?text=Bonjour%20Kamer%20Drive,%20j'ai%20besoin%20d'aide.";
                              _launchUrl(whatsappUrl, context);
                            },
                          ),
                          const SizedBox(width: 15),
                          _buildContactCard(
                            context: context,
                            icon: Icons.phone_outlined,
                            title: "Appeler",
                            color: Colors.blue,
                            onTap: () {
                              // Remplace par le numéro du SAV
                              final phoneUrl = "tel:+237600000000";
                              _launchUrl(phoneUrl, context);
                            },
                          ),
                          const SizedBox(width: 15),
                          _buildContactCard(
                            context: context,
                            icon: Icons.email_outlined,
                            title: "Email",
                            color: Colors.orange,
                            onTap: () {
                              // Remplace par l'email de ton support
                              final emailUrl =
                                  "mailto:support@kamerdrive.com?subject=Support%20Application";
                              _launchUrl(emailUrl, context);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // --- SECTION FAQ ---
                      const Text(
                        "Foire Aux Questions (FAQ)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildFaqItem(
                        question: "Comment louer un véhicule ?",
                        answer:
                            "Pour louer un véhicule, naviguez vers la page d'accueil, choisissez un véhicule avec l'étiquette 'Location', sélectionnez vos dates et procédez au paiement. Assurez-vous d'avoir ajouté vos documents d'identité dans votre profil.",
                      ),
                      _buildFaqItem(
                        question: "Quels sont les documents requis ?",
                        answer:
                            "Vous devez fournir une pièce d'identité valide (CNI ou Passeport) ainsi qu'un permis de conduire pour pouvoir louer un véhicule sur Kamer Drive.",
                      ),
                      _buildFaqItem(
                        question:
                            "Comment mettre mon véhicule en vente ou en location ?",
                        answer:
                            "Allez dans l'onglet 'Mes véhicules' et cliquez sur 'Ajouter'. Remplissez les informations, choisissez 'Vente' ou 'Location', et ajoutez les photos et documents de la voiture. Votre annonce sera publiée après validation par notre équipe.",
                      ),
                      _buildFaqItem(
                        question: "Comment fonctionnent les paiements ?",
                        answer:
                            "Les paiements sont sécurisés. Vous pouvez payer par Mobile Money (Orange/MTN) ou par carte bancaire. Pour la location, une caution peut être retenue et vous sera restituée à la fin de la location.",
                      ),
                      _buildFaqItem(
                        question: "Que faire en cas de panne ou d'accident ?",
                        answer:
                            "En cas de problème, sécurisez le véhicule et contactez immédiatement notre support client via le bouton WhatsApp ou Appel ci-dessus. Nous vous indiquerons la marche à suivre.",
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

  // --- WIDGET HELPER POUR LES CARTES DE CONTACT ---
  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER POUR LA FAQ (Menus déroulants) ---
  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
        ), // Enlève la ligne moche de l'ExpansionTile
        child: ExpansionTile(
          iconColor: kPrimaryColor,
          collapsedIconColor: Colors.grey,
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
