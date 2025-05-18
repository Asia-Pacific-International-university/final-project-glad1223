// *** File: lib/presentation/screens/home/home_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // Import auth provider
import '../settings_screen.dart'; // Import settings screen route
import '../../widgets/app_drawer.dart'; // Assuming you have an AppDrawer widget

// The main screen displayed after successful login.
// This will likely contain the main navigation (e.g., BottomNavigationBar)
// to access Leaderboard, Profile, Quests, etc.
class HomeScreen extends StatelessWidget {
  static const routeName = '/home'; // Route name for navigation

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider to react to user changes (like sign-in/out)
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isAdmin = authProvider.isAdmin(); // Use the helper method

    // Handle case where user is not logged in (shouldn't happen if route is protected)
    if (currentUser == null) {
      // Redirect to login or splash screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushReplacementNamed('/login'); // Use your AppRouter
      });
      return const Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator())); // Show loading while redirecting
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse'),
        automaticallyImplyLeading: false, // Don't show back button on home
        // Add a logout button for testing
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              // Navigate back to login/splash after logout
              Navigator.of(context)
                  .pushReplacementNamed('/login'); // Use your AppRouter
            },
          ),
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
      drawer: const AppDrawer(), // Your app drawer
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${currentUser.username}!'),
            Text(
                'Your Faculty: ${currentUser.facultyId}'), // Display faculty ID
            Text(
                'Total Points: ${currentUser.totalPoints ?? 0}'), // Display points

            const SizedBox(height: 40),

            // Conditionally display Admin features
            if (isAdmin)
              Column(
                children: [
                  const Text('Admin Dashboard Options:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Quest Management Screen
                      // Using your AppRouter:
                      // Navigator.of(context).pushNamed('/admin/quest_management'); // Replace with actual route
                      print('Navigate to Quest Management'); // Placeholder
                    },
                    child: const Text('Manage Quests'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Admin Leaderboard/User Monitoring Screen
                      // Navigator.of(context).pushNamed('/admin/user_monitoring'); // Replace with actual route
                      print('Navigate to User Monitoring'); // Placeholder
                    },
                    child: const Text(
                        'Monitor Users/Leaderboard'), // Match the privilege description
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Quest Completion Rate Screen
                      // Navigator.of(context).pushNamed('/admin/quest_completion_rates'); // Replace with actual route
                      print(
                          'Navigate to Quest Completion Rates'); // Placeholder
                    },
                    child: const Text(
                        'View Quest Completion Rates'), // Match the privilege description
                  ),
                  // Add buttons for Announcements and Faculty List Management if those screens exist
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Settings for Admins (contains announcements/faculty edit)
                      // Navigator.of(context).pushNamed('/admin/settings'); // Replace with actual route
                      print('Navigate to Admin Settings'); // Placeholder
                    },
                    child: const Text(
                        'Admin Settings (Announcements, Faculties)'), // Match the privilege description
                  ),
                ],
              )
            else
              // Display regular user content
              Column(
                children: [
                  const Text('Your User Features Here',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Leaderboard
                      // Navigator.of(context).pushNamed('/leaderboard'); // Replace with actual route
                      print('Navigate to User Leaderboard'); // Placeholder
                    },
                    child: const Text('View Leaderboard'),
                  ),
                  // ... other user features like viewing profile, active quests etc.
                ],
              ),
          ],
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

// // *** File: lib/presentation/screens/home/home_screen.dart ***

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project/presentation/screens/settings_screen.dart'; // Import settings screen route
// import 'package:final_project/presentation/providers/auth_provider.dart'; // Import auth provider

// // The main screen displayed after successful login.
// // This will likely contain the main navigation (e.g., BottomNavigationBar)
// // to access Leaderboard, Profile, Quests, etc.
// class HomeScreen extends StatelessWidget {
//   static const routeName = '/home'; // Route name for navigation

//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Access user data from AuthProvider
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.user; // Get the User object

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Campus Pulse Home'),
//         automaticallyImplyLeading: false, // Don't show back button on home
//         actions: [
//           // Action button to navigate to Settings
//           IconButton(
//             icon: const Icon(Icons.settings),
//             tooltip: 'Settings',
//             onPressed: () {
//               Navigator.of(context).pushNamed(SettingsScreen.routeName);
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome!',
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//               const SizedBox(height: 10),
//               // Display user info by accessing the email property of the User object
//               if (user != null && user.email != null)
//                 Text('Email: ${user.email}'),
//               if (authProvider.selectedFaculty != null)
//                 Text('Faculty: ${authProvider.selectedFaculty}'),
//               const SizedBox(height: 40),
//               const Text(
//                 'Leaderboard and Active Quests will appear here.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//               ),
//               // TODO: Add BottomNavigationBar or other navigation elements
//               // TODO: Display Leaderboard summary widget
//               // TODO: Display current/next quest info widget
//             ],
//           ),
//         ),
//       ),
//       // Example: Add a BottomNavigationBar later
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items: const [
//       //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//       //     BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
//       //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//       //   ],
//       //   // Handle navigation between tabs
//       // ),
//     );
//   }
// }
