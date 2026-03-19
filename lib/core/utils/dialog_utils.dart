import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';

/// Affiche une modale "Bientôt disponible" personnalisable.
/// Parfaite pour bloquer les boutons de fonctionnalités en cours de dev.
void showComingSoonDialog(
  BuildContext context, {
  String title = "Bientôt disponible",
  String message =
      "Cette fonctionnalité est en cours de développement.\n\nRestez à l'écoute pour la prochaine mise à jour !",
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          height: 1.5,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            "J'ai compris",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
