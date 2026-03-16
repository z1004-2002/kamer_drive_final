import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';


class KamerDriveLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final Color? textColor;

  const KamerDriveLogo({
    Key? key,
    this.size = 40.0,
    this.showText = true,
    this.color, // Couleur de l'icône/logo (par défaut kPrimaryColor)
    this.textColor, // Couleur du texte (par défaut kPrimaryColor ou Noir)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Couleurs par défaut si non spécifiées
    final iconColor = color ?? kPrimaryColor;
    final finalTextColor = textColor ?? kPrimaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- 1. L'IMAGE OU L'ICÔNE ---
        // Si tu as ton image logo.png, décommente la ligne ci-dessous et commente le Container
        
        Image.asset(
          'assets/images/logo/logo.png',
          height: size * 1.5,
        ),
        
        

        // --- 2. LE TEXTE (Optionnel) ---
        if (showText) ...[
          SizedBox(height: size * 0.2), // Espace proportionnel à la taille
          Text(
            "KamerDrive",
            style: TextStyle(
              fontSize: size * 0.5, // Le texte fait la moitié de la taille de l'icône
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: finalTextColor,
            ),
          ),
        ]
      ],
    );
  }
}