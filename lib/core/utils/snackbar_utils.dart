import 'package:flutter/material.dart';

class SnackbarUtils {
  // 1. Message de SUCCÈS
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green.shade600, Icons.check_circle);
  }

  // 2. Message d'ERREUR
  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red.shade600, Icons.error_outline);
  }

  // 3. Message d'AVERTISSEMENT
  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.orange.shade600, Icons.warning_amber_rounded);
  }

  // Fonction privée qui gère le design commun
  static void _showSnackbar(BuildContext context, String message, Color color, IconData icon) {
    // Masquer le snackbar actuel s'il y en a déjà un à l'écran
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 15, 
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2, // Permet au texte de passer sur 2 lignes si besoin
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Le rend flottant (ne touche pas le bas de l'écran)
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // Marges extérieures
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Bords très arrondis
        ),
        elevation: 6, // Petite ombre
        duration: const Duration(seconds: 3), // Disparaît après 3 secondes
      ),
    );
  }
}