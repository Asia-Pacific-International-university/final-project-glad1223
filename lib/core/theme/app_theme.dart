import 'package:flutter/material.dart';

/// Defines the application's light and dark themes.
class AppTheme {
  // Define a primary color swatch
  static const MaterialColor primaryColorSwatch =
      Color.fromARGB(255, 0, 40, 70);
  static const int _primaryColorValue = 0xFF2196F3; // A shade of blue

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: primaryColorSwatch,
    primaryColor: primaryColorSwatch[500],
    colorScheme: ColorScheme.light(
      primary: primaryColorSwatch[500]!,
      secondary: Colors.tealAccent[400]!, // Example secondary color
      surface: Colors.white,
      background: Colors.white,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColorSwatch[500],
      foregroundColor: Colors.white, // Title and icon color
      elevation: 4.0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColorSwatch[500],
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorSwatch[500],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    textTheme: const TextTheme(
      // Define various text styles
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14.0),
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    ),
    // Add more theme customizations as needed
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: primaryColorSwatch,
    primaryColor:
        primaryColorSwatch[500], // Can choose a different shade for dark mode
    colorScheme: ColorScheme.dark(
      primary: primaryColorSwatch[500]!,
      secondary: Colors.tealAccent[400]!, // Example secondary color
      surface: const Color(0xFF1E1E1E), // Dark surface color
      background: const Color(0xFF121212), // Dark background color
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white70,
      onBackground: Colors.white70,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E), // Darker app bar
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColorSwatch[500],
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorSwatch[500],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[800], // Darker fill color for input fields
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: const Color(0xFF1E1E1E), // Darker card color
    ),
    textTheme: const TextTheme(
      // Define various text styles for dark mode
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
      labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    // Add more dark theme customizations as needed
  );
}
