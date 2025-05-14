import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;

  const AuthTextField(
      {super.key,
      this.hintText,
      required this.controller,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
