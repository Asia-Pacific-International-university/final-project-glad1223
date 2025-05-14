/// Contains application-wide constant values.
class AppConstants {
  // Basic app information
  static const String appName = 'Campus Pulse Challenge';

  // Routing paths (using GoRouter syntax)
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String facultySelectionRoute = '/faculty-selection';
  static const String homeRoute = '/home';
  static const String leaderboardRoute = '/leaderboard';
  static const String profileRoute = '/profile';
  static const String activeQuestRoute = '/active-quest';
  static const String questResultRoute = '/quest-result';
  static const String settingsRoute = '/settings';

  // Add other constants as needed, e.g., API base URLs, timeouts, etc.
  // static const String apiBaseUrl = 'YOUR_API_BASE_URL';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration questTimerDuration = Duration(
    seconds: 60,
  ); // Example quest time limit
}
