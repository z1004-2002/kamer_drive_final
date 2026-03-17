  // --- TITRE DE SECTION ---
import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';

Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "Voir tout",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }