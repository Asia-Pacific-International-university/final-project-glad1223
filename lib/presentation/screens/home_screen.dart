// *** File: lib/presentation/screens/home/home_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/presentation/screens/settings_screen.dart'; // Import settings screen route
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import auth provider

// The main screen displayed after successful login.
// This will likely contain the main navigation (e.g., BottomNavigationBar)
// to access Leaderboard, Profile, Quests, etc.
class HomeScreen extends StatelessWidget {
  static const routeName = '/home'; // Route name for navigation

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user data from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user; // Get the User object

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse Home'),
        automaticallyImplyLeading: false, // Don't show back button on home
        actions: [
          // Action button to navigate to Settings
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              // Display user info by accessing the email property of the User object
              if (user != null && user.email != null)
                Text('Email: ${user.email}'),
              if (authProvider.selectedFaculty != null)
                Text('Faculty: ${authProvider.selectedFaculty}'),
              const SizedBox(height: 40),
              const Text(
                'Leaderboard and Active Quests will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              // TODO: Add BottomNavigationBar or other navigation elements
              // TODO: Display Leaderboard summary widget
              // TODO: Display current/next quest info widget
            ],
          ),
        ),
      ),
      // Example: Add a BottomNavigationBar later
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      //   // Handle navigation between tabs
      // ),
    );
  }
}
