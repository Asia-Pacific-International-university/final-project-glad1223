// *** File: lib/presentation/screens/settings/settings_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/presentation/providers/theme_provider.dart'; // Import theme provider
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import auth provider
import 'package:final_project/presentation/screens/auth/login_screen.dart'; // Import login screen route

// Screen for application settings.
// Includes theme toggling and logout functionality.
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings'; // Route name for navigation

  const SettingsScreen({super.key});

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // Navigate back to login screen and remove all previous routes
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (Route<dynamic> route) => false, // Remove all routes below login
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider to get/set theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Use ListView for potentially more settings later
          children: <Widget>[
            // --- Theme Settings ---
            Card(
              // Wrap theme settings in a card for better visual grouping
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // Theme Mode Switch (using Radio buttons for clarity)
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      secondary: const Icon(Icons.brightness_auto),
                      value: ThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      secondary: const Icon(Icons.brightness_5), // Sun icon
                      value: ThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      secondary: const Icon(Icons.brightness_4), // Moon icon
                      value: ThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                    // Alternative: Simple Switch for toggling Light/Dark only
                    // SwitchListTile(
                    //   title: const Text('Dark Mode'),
                    //   secondary: const Icon(Icons.brightness_6),
                    //   value: themeProvider.themeMode == ThemeMode.dark,
                    //   onChanged: (bool value) {
                    //     themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24), // Spacing
            // --- Account Settings ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _logout(context), // Call logout function
              ),
            ),

            // Add other settings sections here (e.g., Notifications, Profile Editing)
          ],
        ),
      ),
    );
  }
}
