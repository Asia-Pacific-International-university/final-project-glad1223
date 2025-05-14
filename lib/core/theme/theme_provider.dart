import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's theme (light/dark mode).
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  static const String _themeKey = 'selectedTheme'; // Key for SharedPreferences

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    // Load saved theme preference when the provider is created
    _loadThemePreference();
  }

  /// Sets the theme mode and saves the preference.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners(); // Notify listeners (UI) that the theme has changed
      _saveThemePreference(mode); // Save the new preference
    }
  }

  /// Loads the theme preference from SharedPreferences.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode =
          ThemeMode.system; // Default if no preference saved or invalid
    }
    notifyListeners(); // Notify after loading
  }

  /// Saves the current theme mode to SharedPreferences.
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, themeString);
  }

  /// Toggles the current theme mode.
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.light); // Default toggle behavior from system
    }
  }
}
