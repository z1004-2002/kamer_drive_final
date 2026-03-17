import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: const [
          Expanded(child: Divider(color: Color(0xFFE0E0E0), height: 1.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text("OU", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Divider(color: Color(0xFFE0E0E0), height: 1.5)),
        ],
      ),
    );
  }
}