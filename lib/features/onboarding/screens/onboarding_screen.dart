import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';

// Modèle de données pour l'onboarding
class OnboardingContents {
  final String title;
  final String image;
  final String desc;
  final IconData icon;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // MISE À JOUR MVP : Location, Vente/Achat, Sécurité
  final List<OnboardingContents> contents = [
    OnboardingContents(
      title: "Location",
      image: "assets/images/onboard/rental.png",
      desc:
          "Louer un véhicule n'a jamais été aussi simple. Trouvez la voiture parfaite ou rentabilisez la vôtre en quelques clics.",
      icon: Icons.car_rental,
    ),
    OnboardingContents(
      title: "Achat & Vente",
      image:
          "assets/images/onboard/sale.png", // Assure-toi d'avoir cette image (ou utilise welcome.png)
      desc:
          "Vendez votre véhicule au meilleur prix ou trouvez la voiture de vos rêves. Des transactions claires et directes.",
      icon: Icons.sell,
    ),
    OnboardingContents(
      title: "100% Sécurisé",
      image: "assets/images/onboard/welcome.png",
      desc:
          "Bienvenue sur KamerDrive ! Chaque véhicule et utilisateur est vérifié par notre équipe pour garantir votre sécurité.",
      icon: Icons.verified_user,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Cercles décoratifs (Ton design)
            Positioned(
              left: -size.width * 0.45,
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
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: const BoxDecoration(
                  color: kSecondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Contenu
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Name(size: 30),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(contents[index].image, height: 280),
                                const SizedBox(height: 40),
                                Text(
                                  contents[index].title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  contents[index].desc,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicateurs (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => buildDot(index, context),
                  ),
                ),

                // Boutons de navigation
                Container(
                  height: 60,
                  margin: const EdgeInsets.all(40),
                  width: double.infinity,
                  child: _currentIndex == contents.length - 1
                      ? ElevatedButton(
                          onPressed: () {
                            // REDIRECTION PROPRE VERS L'AUTH
                            context.go('/auth');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Commencer !",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                _controller.jumpToPage(contents.length - 1);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: dPrimaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Passer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Suivant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 6,
      width: _currentIndex == index ? 25 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentIndex == index ? kPrimaryColor : Colors.grey.shade300,
      ),
    );
  }
}
