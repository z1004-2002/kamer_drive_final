import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/features/auth/providers/auth_provider.dart';
import 'package:kamer_drive_final/shared/widgets/logo.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
  void initState() {
    super.initState();
    
    // Au lieu d'un simple délai, on attend de vérifier l'état de connexion
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        // Appelle la fonction Auto-Login
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final String nextRoute = await authProvider.checkAuthStateAndRoute();
        
        if (mounted) {
          context.go(nextRoute); // Va vers /home, /profiling ou /onboarding
        }
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
