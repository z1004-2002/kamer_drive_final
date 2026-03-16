import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/shared/widgets/logo.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      // On vérifie que le widget est toujours actif avant de naviguer
      if (mounted) {
        context.go('/onboarding'); // Navigation propre
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          // Cercle décoratif Haut-Gauche
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

          // Cercle décoratif Bas-Droite
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

          // Contenu Central
          Center(
            child: KamerDriveLogo(
              size: 100, // Très grand
              showText: true,
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Container(
            //       color: Colors.white,
            //       child: Image.asset(
            //         'assets/images/logo/logo.png',
            //         width: size.width * 0.5,
            //       ),
            //     ),
            //     Name(size: 30),
            //     Container(
            //       color: Colors.white,
            //       child: CupertinoActivityIndicator(
            //         animating: true,
            //         radius: size.width * 0.05,
            //         color: kPrimaryColor,
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }
}
