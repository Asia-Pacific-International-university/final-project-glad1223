// // *** File: lib/presentation/screens/splash/splash_screen.dart ***

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project/presentation/screens/auth/login_screen.dart'; // Import login screen route
// import 'package:final_project/presentation/screens/home_screen.dart'; // Import home screen route
// import 'package:final_project/presentation/providers/auth_provider.dart'; // Import auth provider

// // A simple splash screen displayed when the app starts.
// // Typically used for initialization tasks (e.g., checking auth status).
// class SplashScreen extends StatefulWidget {
//   static const routeName = '/splash'; // Route name for navigation

//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp(); // Start initialization logic
//   }

//   // Simulates app initialization and checks authentication status.
//   Future<void> _initializeApp() async {
//     // Simulate loading time or actual initialization tasks
//     await Future.delayed(const Duration(seconds: 2));

//     // Check authentication status using the AuthProvider
//     // Use `listen: false` because we are in initState
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider
//         .checkInitialAuthStatus(); // Check if user is already logged in

//     // Navigate based on login status
//     if (mounted) {
//       // Check if the widget is still in the tree
//       if (authProvider.user != null) {
//         // Changed to check if user is not null
//         Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
//       } else {
//         Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Basic splash screen UI
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Replace with your app logo
//             const Icon(
//               // Changed to const
//               Icons
//                   .school, // Changed to a valid icon.  campus_updates_rounded does not exist in flutter
//               size: 100,
//               color: Colors.blue, //Added a color
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Campus Pulse Challenge',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// *** File: lib/presentation/screens/splash/splash_screen.dart ***

import 'package:flutter/material.dart';
import 'package:final_project/presentation/screens/auth/login_screen.dart'; // Import login screen route

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
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
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
            const Icon(
              Icons.school,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Campus Pulse Challenge',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
