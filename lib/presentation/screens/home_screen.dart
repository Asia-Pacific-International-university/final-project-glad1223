import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../settings_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider.select((state) => state.user));
    final isAdmin = ref.watch(
        authProvider.select((state) => state.user?.role == UserRole.admin));
    final authNotifier = ref.read(authProvider.notifier);

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go(AppConstants.loginRoute); // Use GoRouter
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse'),
        automaticallyImplyLeading: false,
        actions: [
          // Logout IconButton with increased tap target
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4.0), // Add some padding
            child: Material(
              // Wrap in Material to control tap area
              type: MaterialType.transparency, // Make it transparent
              child: InkWell(
                // Provides ripple effect
                customBorder: const CircleBorder(), // Keep circular ripple
                onTap: () async {
                  await authNotifier.signOut();
                  GoRouter.of(context)
                      .go(AppConstants.loginRoute); // Use GoRouter
                },
                child: const SizedBox(
                  // Explicitly set tap target size
                  width: 48.0, // Minimum 48x48 for Material Design guidelines
                  height: 48.0,
                  child: Center(
                    child: Icon(Icons.logout),
                  ),
                ),
              ),
            ),
          ),
          // Settings IconButton with increased tap target
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4.0), // Add some padding
            child: Material(
              // Wrap in Material to control tap area
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  GoRouter.of(context)
                      .push(SettingsScreen.routeName); // Use GoRouter
                },
                child: const SizedBox(
                  // Explicitly set tap target size
                  width: 48.0,
                  height: 48.0,
                  child: Center(
                    child: Icon(Icons.settings),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${currentUser.username}!',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall, // Use theme text style for better scaling
            ),
            Text(
              'Your Faculty: ${currentUser.facultyName ?? 'N/A'}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium, // Use theme text style
            ),
            Text(
              'Total Points: ${currentUser.totalPoints}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium, // Use theme text style
            ),
            const SizedBox(height: 40),
            if (isAdmin)
              Column(
                children: [
                  Text(
                    'Admin Dashboard Options:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight:
                            FontWeight.bold), // Use theme style and copyWith
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Quest Management');
                      // TODO: Navigate to Quest Management Screen
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                          200, 50), // Ensure minimum size for tap target
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Manage Quests'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to User Monitoring');
                      // TODO: Navigate to User Monitoring Screen
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Monitor Users/Leaderboard'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Quest Completion Rates');
                      // TODO: Navigate to Quest Completion Rates Screen
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('View Quest Completion Rates'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Admin Settings');
                      // TODO: Navigate to Admin Settings Screen
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child:
                        const Text('Admin Settings (Announcements, Faculties)'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    'Your User Features Here',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight:
                            FontWeight.bold), // Use theme style and copyWith
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to User Leaderboard');
                      GoRouter.of(context)
                          .push(AppConstants.leaderboardRoute); // Use GoRouter
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('View Leaderboard'),
                  ),
                  // TODO: Add other user-specific navigation buttons here, e.g., Active Quest
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Active Quest');
                      GoRouter.of(context)
                          .push(AppConstants.activeQuestRoute); // Use GoRouter
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Start/View Active Quest'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
