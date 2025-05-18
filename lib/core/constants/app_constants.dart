// lib/core/constants/app_constants.dart

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

enum UserRole {
  user, // Regular user
  admin, // Administrator
}

// Helper to convert enum to string and back
extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;
}

UserRole? userRoleFromString(String? roleName) {
  if (roleName == null) return null;
  try {
    return UserRole.values.firstWhere(
      (e) => e.name == roleName.toLowerCase(),
    );
  } catch (e) {
    return null; // Handle cases where the string doesn't match
  }
}

// Define Faculty IDs and names
class AppFaculties {
  static const String artsAndHumanities = 'arts_humanities';
  static const String businessAdministration = 'business_admin';
  static const String education = 'education';
  static const String informationTechnology = 'it';
  static const String nursing = 'nursing';
  static const String religiousStudies = 'religious_studies';
  static const String science = 'science';

  // Map IDs to Names for display
  static const Map<String, String> facultyMap = {
    artsAndHumanities: 'Faculty of Arts & Humanities',
    businessAdministration: 'Faculty of Business Administration',
    education: 'Faculty of Education',
    informationTechnology: 'Faculty of Information Technology',
    nursing: 'Faculty of Nursing',
    religiousStudies: 'Faculty of Religious Studies',
    science: 'Faculty of Science',
  };

  // Get Name from ID
  static String getFacultyName(String id) {
    return facultyMap[id] ?? 'Unknown Faculty';
  }

  // Get ID from Name (useful for mapping user input)
  static String? getFacultyId(String name) {
    return facultyMap.entries
        .firstWhere(
          (entry) => entry.value == name,
          orElse: () =>
              const MapEntry('', null), // Return null value if not found
        )
        .key;
  }

  // Get list of faculty entries for UI dropdowns
  static List<MapEntry<String, String>> get facultyList =>
      facultyMap.entries.toList();
}

// Define custom exceptions for better error handling
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
  @override
  String toString() => 'AuthenticationException: $message';
}

class InvalidCredentialsException extends AuthenticationException {
  const InvalidCredentialsException(String message) : super(message);
}

class EmailAlreadyInUseException extends AuthenticationException {
  const EmailAlreadyInUseException(String message) : super(message);
}

class UserNotFoundException extends ServerException {
  const UserNotFoundException(String message) : super(message);
}

// A generic failure class for domain layer
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class OtherFailure extends Failure {
  const OtherFailure(String message) : super(message);
}


// ... other constants


// /// Contains application-wide constant values.
// class AppConstants {
//   // Basic app information
//   static const String appName = 'Campus Pulse Challenge';

//   // Routing paths (using GoRouter syntax)
//   static const String splashRoute = '/';
//   static const String loginRoute = '/login';
//   static const String signupRoute = '/signup';
//   static const String facultySelectionRoute = '/faculty-selection';
//   static const String homeRoute = '/home';
//   static const String leaderboardRoute = '/leaderboard';
//   static const String profileRoute = '/profile';
//   static const String activeQuestRoute = '/active-quest';
//   static const String questResultRoute = '/quest-result';
//   static const String settingsRoute = '/settings';

//   // Add other constants as needed, e.g., API base URLs, timeouts, etc.
//   // static const String apiBaseUrl = 'YOUR_API_BASE_URL';

//   // Durations
//   static const Duration splashDuration = Duration(seconds: 2);
//   static const Duration questTimerDuration = Duration(
//     seconds: 60,
//   ); // Example quest time limit
// }
