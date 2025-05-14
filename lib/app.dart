import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/core/navigation/app_router.dart';
import 'package:final_project/core/theme/theme_provider.dart';
import 'package:final_project/core/constants/app_constants.dart';
import 'package:final_project/core/theme/app_theme.dart';
// Import AuthProvider once created
// import 'package:final_project/presentation/providers/auth_provider.dart';

/// The root widget of the application.
class CampusPulseChallengeApp extends StatelessWidget {
  const CampusPulseChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Access the AppRouter instance
    final appRouter = Provider.of<AppRouter>(context).router;

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme, // Use the light theme
      darkTheme: AppTheme.darkTheme, // Use the dark theme
      themeMode:
          themeProvider.themeMode, // Set theme mode based on ThemeProvider
      debugShowCheckedModeBanner: false, // Hide debug banner
      // Use routerConfig for GoRouter
      routerConfig: appRouter,

      // You can add global localization delegates here later
      // localizationsDelegates: const [
      //    // ... delegates
      // ],
      // supportedLocales: const [
      //    // ... locales
      // ],
    );
  }
}
