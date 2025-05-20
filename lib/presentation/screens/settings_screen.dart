import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:final_project/presentation/providers/theme_provider.dart'; // Import theme provider
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import auth provider
import 'package:final_project/core/constants/app_constants.dart'; // Import AppConstants for login route
import 'package:go_router/go_router.dart'; // Import GoRouter

// Screen for application settings.
// Includes theme toggling and logout functionality.
class SettingsScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  static const routeName = '/settings'; // Route name for navigation

  const SettingsScreen({super.key});

  // Function to handle logout
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Added WidgetRef
    final authNotifier =
        ref.read(authProvider.notifier); // Use Riverpod to read notifier
    await authNotifier.signOut();
    // Navigate back to login screen and remove all previous routes
    if (context.mounted) {
      GoRouter.of(context)
          .go(AppConstants.loginRoute); // Use GoRouter for replacement
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    // Access ThemeProvider to get/set theme mode
    final themeProvider =
        ref.watch(themeProvider.notifier); // Use Riverpod to watch notifier
    final currentThemeMode =
        ref.watch(themeModeProvider); // Watch the theme mode directly

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // --- Theme Settings ---
            Card(
              margin: const EdgeInsets.only(
                  bottom: 16.0), // Add margin for spacing between cards
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge, // Good for scaling
                    ),
                    const SizedBox(height: 8),
                    // Theme Mode Radio buttons - inherently good tap targets
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      secondary: const Icon(Icons.brightness_auto),
                      value: ThemeMode.system,
                      groupValue: currentThemeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      secondary: const Icon(Icons.brightness_5),
                      value: ThemeMode.light,
                      groupValue: currentThemeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      secondary: const Icon(Icons.brightness_4),
                      value: ThemeMode.dark,
                      groupValue: currentThemeMode,
                      onChanged: (value) => themeProvider.setThemeMode(value!),
                    ),
                  ],
                ),
              ),
            ),
            // --- Account Settings ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () =>
                    _logout(context, ref), // Pass ref to logout function
                // ListTile itself provides a good tap target size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
