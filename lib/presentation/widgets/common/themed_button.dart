import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:final_project/core/theme/theme_provider.dart'; // Import Riverpod theme provider
import 'package:final_project/core/theme/app_theme.dart'; // Your AppTheme
import 'package:final_project/core/riverpodDI/providers.dart';

class ThemedButton extends ConsumerWidget {
  // Changed to ConsumerWidget
  final String text;
  final VoidCallback? onPressed; // Made nullable to disable button
  final bool isLoading; // Added isLoading property

  const ThemedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    final themeMode =
        ref.watch(themeModeProvider); // Watch the theme mode from Riverpod
    final currentTheme =
        themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Disable if isLoading is true
      style: ElevatedButton.styleFrom(
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: currentTheme.colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 50), // Full width button
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: isLoading
          ? const SizedBox(
              // Show spinner when loading
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : Text(text),
    );
  }
}
