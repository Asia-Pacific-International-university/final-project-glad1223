import 'package:go_router/go_router.dart';
import 'package:final_project/core/constants/app_constants.dart';
import 'package:final_project/presentation/screens/splash_screen.dart';
import 'package:final_project/presentation/screens/auth/login_screen.dart';
import 'package:final_project/presentation/screens/auth/signup_screen.dart';
import 'package:final_project/presentation/screens/auth/faculty_selection_screen.dart';
import 'package:final_project/presentation/screens/home_screen.dart';
import 'package:final_project/presentation/screens/leaderboard_screen.dart';
import 'package:final_project/presentation/screens/profile_screen.dart';
import 'package:final_project/presentation/screens/quest/active_quest_screen.dart';
import 'package:final_project/presentation/screens/quest/quest_result_screen.dart';
import 'package:final_project/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart'; // Import AuthProvider

/// Defines the application's routing using GoRouter.
class AppRouter {
  // GoRouter configuration
  late final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute, // Start at the splash screen
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.signupRoute,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppConstants.facultySelectionRoute,
        builder: (context, state) => const FacultySelectionScreen(),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.leaderboardRoute,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.activeQuestRoute,
        builder: (context, state) => const ActiveQuestScreen(),
      ),
      GoRoute(
        path: AppConstants.questResultRoute,
        builder: (context, state) => const QuestResultScreen(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Add more routes for other screens as you create them
    ],
    // Add redirect logic here later based on authentication state, etc.
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool loggedIn = authProvider.currentUser != null;
      final bool loggingIn = state.matchedLocation == AppConstants.loginRoute ||
          state.matchedLocation == AppConstants.signupRoute;
      final bool selectingFaculty =
          state.matchedLocation == AppConstants.facultySelectionRoute;

      if (!loggedIn) {
        return loggingIn
            ? null
            : AppConstants
                .loginRoute; // Redirect to login if not logged in and not already on auth pages
      }

      // Redirect to home if logged in and trying to access auth pages
      if (loggingIn) {
        return AppConstants.homeRoute;
      }

      // Redirect to faculty selection if logged in but faculty not selected
      if (loggedIn &&
          authProvider.requiresFacultySelection() &&
          !selectingFaculty) {
        return AppConstants.facultySelectionRoute;
      }

      // Redirect to home if logged in and faculty is selected and trying to access faculty selection
      if (loggedIn &&
          !authProvider.requiresFacultySelection() &&
          selectingFaculty) {
        return AppConstants.homeRoute;
      }

      return null; // No redirect needed
    },
    // Add error handling for unknown routes if needed
    // errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// --- No changes needed in the AppConstants for the routes themselves ---
// --- The MaterialApp setup in main.dart would now use GoRouter's router ---

// import 'package:go_router/go_router.dart';
// //import 'package:flutter/material.dart';
// import 'package:final_project/core/constants/app_constants.dart';
// import 'package:final_project/presentation/screens/splash_screen.dart';
// import 'package:final_project/presentation/screens/auth/login_screen.dart';
// import 'package:final_project/presentation/screens/auth/signup_screen.dart';
// import 'package:final_project/presentation/screens/auth/faculty_selection_screen.dart';
// import 'package:final_project/presentation/screens/home_screen.dart';
// import 'package:final_project/presentation/screens/leaderboard_screen.dart';
// import 'package:final_project/presentation/screens/profile_screen.dart';
// import 'package:final_project/presentation/screens/quest/active_quest_screen.dart';
// import 'package:final_project/presentation/screens/quest/quest_result_screen.dart';
// import 'package:final_project/presentation/screens/settings_screen.dart';

// /// Defines the application's routing using GoRouter.
// class AppRouter {
//   // GoRouter configuration
//   late final GoRouter router = GoRouter(
//     initialLocation: AppConstants.splashRoute, // Start at the splash screen
//     routes: [
//       GoRoute(
//         path: AppConstants.splashRoute,
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.loginRoute,
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.signupRoute,
//         builder: (context, state) => const SignupScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.facultySelectionRoute,
//         builder: (context, state) => const FacultySelectionScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.homeRoute,
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.leaderboardRoute,
//         builder: (context, state) => const LeaderboardScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.profileRoute,
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.activeQuestRoute,
//         builder: (context, state) => const ActiveQuestScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.questResultRoute,
//         builder: (context, state) => const QuestResultScreen(),
//       ),
//       GoRoute(
//         path: AppConstants.settingsRoute,
//         builder: (context, state) => const SettingsScreen(),
//       ),
//       // Add more routes for other screens as you create them
//     ],
//     // Add redirect logic here later based on authentication state, etc.
//     // redirect: (context, state) {
//     //   final bool loggedIn = // Check auth status here (e.g., from AuthProvider);
//     //   final bool loggingIn = state.matchedLocation == AppConstants.loginRoute || state.matchedLocation == AppConstants.signupRoute;
//     //
//     //   if (!loggedIn) {
//     //     return loggingIn ? null : AppConstants.loginRoute; // Redirect to login if not logged in and not already on auth pages
//     //   }
//     //
//     //   // Redirect to home if logged in and trying to access auth pages
//     //   if (loggingIn) {
//     //     return AppConstants.homeRoute;
//     //   }
//     //
//     //   return null; // No redirect needed
//     // },
//     // Add error handling for unknown routes if needed
//     // errorBuilder: (context, state) => ErrorScreen(error: state.error),
//   );
// }
