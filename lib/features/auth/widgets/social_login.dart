import 'package:flutter/material.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(Icons.facebook, const Color(0xFF4267B2)),
        const SizedBox(width: 20),
        _buildSocialIcon(Icons.g_mobiledata, const Color(0xFFDB4437)),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}