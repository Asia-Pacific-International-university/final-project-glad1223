import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../settings_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../core/constants/app_constants.dart';

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
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut();
              Navigator.of(context)
                  .pushReplacementNamed(AppConstants.loginRoute);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${currentUser.username}!'),
            Text('Your Faculty: ${currentUser.facultyName ?? 'N/A'}'),
            Text('Total Points: ${currentUser.totalPoints}'),
            const SizedBox(height: 40),
            if (isAdmin)
              Column(
                children: [
                  const Text('Admin Dashboard Options:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Quest Management');
                    },
                    child: const Text('Manage Quests'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to User Monitoring');
                    },
                    child: const Text('Monitor Users/Leaderboard'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Quest Completion Rates');
                    },
                    child: const Text('View Quest Completion Rates'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to Admin Settings');
                    },
                    child:
                        const Text('Admin Settings (Announcements, Faculties)'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Text('Your User Features Here',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Navigate to User Leaderboard');
                    },
                    child: const Text('View Leaderboard'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
