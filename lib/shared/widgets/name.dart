import 'package:flutter/material.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';

class Name extends StatelessWidget {
  final double size;
  const Name({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Kamer',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
            // fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'Drive',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: dPrimaryColor,
            // fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
