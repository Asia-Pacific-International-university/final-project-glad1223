import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String? labelText; // Changed from hintText for better semantics
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType; // Added for email input
  final String? Function(String?)? validator; // Added for form validation

  const AuthTextField({
    super.key,
    this.labelText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text, // Default to text
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        // Changed to TextFormField for validation support
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText, // Use labelText
          border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(8.0)), // Added rounded corners
          ),
          filled: true, // Make it filled
          fillColor: Theme.of(context)
              .inputDecorationTheme
              .fillColor, // Use theme's fill color
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // Consistent padding
        ),
        validator: validator, // Apply validator
      ),
    );
  }
}
