// *** File: lib/presentation/screens/splash/splash_screen.dart ***

import 'package:flutter/material.dart';
import 'package:final_project/presentation/screens/auth/login_screen.dart'; // Import login screen route
import 'package:go_router/go_router.dart'; // Import GoRouter

// A simple splash screen displayed when the app starts.
// It will navigate to the LoginScreen after a fixed duration.
class SplashScreen extends StatefulWidget {
  static const routeName = '/splash'; // Route name for navigation

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin(); // Start the navigation timer
  }

  // Navigates to the LoginScreen after a fixed delay.
  Future<void> _navigateToLogin() async {
    // Wait for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    // Navigate to the LoginScreen
    if (mounted) {
      GoRouter.of(context).go(LoginScreen.routeName); // Use GoRouter
    }
  }

  @override
  Widget build(BuildContext context) {
    // Basic splash screen UI
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context)
                  .colorScheme
                  .primary, // Use theme primary color for better contrast/theming
            ),
            const SizedBox(height: 20),
            Text(
              'Campus Pulse Challenge',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight:
                      FontWeight.bold), // Use headlineLarge for prominent title
              textAlign: TextAlign.center, // Ensure text wraps correctly
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
