import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/core/theme/theme_provider.dart';

class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ThemedButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: currentTheme.colorScheme.onPrimary,
      ),
      child: Text(text),
    );
  }
}
