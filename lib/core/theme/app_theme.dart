import 'package:flutter/material.dart';

class AppTheme {
  // Define your primary color
  static const Color primaryColor = Color.fromARGB(255, 0, 40, 70);

  // Create a MaterialColor from the primaryColor
  static MaterialColor primaryColorSwatch = _createPrimarySwatch(primaryColor);

  static MaterialColor _createPrimarySwatch(Color color) {
    List<int> strengths = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int strength in strengths) {
      final double ds = 0.5 - (strength / 1000);
      swatch[strength] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

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
