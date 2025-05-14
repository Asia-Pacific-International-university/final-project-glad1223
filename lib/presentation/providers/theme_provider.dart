// *** File: lib/presentation/providers/theme_provider.dart ***

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add shared_preferences to pubspec.yaml

// Manages the application's theme state (light/dark).
// Uses ChangeNotifier to notify listeners when the theme changes.
// Persists the theme preference using SharedPreferences.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  static const String _themePrefKey = 'themeMode'; // Key for SharedPreferences

  ThemeProvider() {
    _loadThemePreference(); // Load saved theme on initialization
  }

  // Getter for the current theme mode.
  ThemeMode get themeMode => _themeMode;

  // Sets the theme mode and notifies listeners.
  // Also saves the preference.
  void setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners(); // Notify UI to rebuild with the new theme
      _saveThemePreference(mode); // Save the selected theme
    }
  }

  // Loads the saved theme preference from SharedPreferences.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.system; // Default if nothing is saved
    }
    // No need to notifyListeners here as it's called during initialization
  }

  // Saves the selected theme preference to SharedPreferences.
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, mode.index);
  }
}
