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

/// Defines the roles a user can have within the application.
enum UserRole {
  user, // A regular participant in quests.
  admin, // An administrator with elevated privileges.
}

/// Helper extension to convert [UserRole] enum to a string and vice-versa.
extension UserRoleExtension on UserRole {
  /// Returns the string representation of the enum value (e.g., 'user', 'admin').
  String get name => toString().split('.').last;
}

/// Converts a nullable string to a [UserRole] enum.
/// Returns null if the string is null or does not match any [UserRole] value.
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

/// Defines the list of faculties available in the university.
class AppFaculties {
  static const String artsAndHumanities = 'arts_humanities';
  static const String businessAdministration = 'business_admin';
  static const String education = 'education';
  static const String informationTechnology = 'it';
  static const String nursing = 'nursing';
  static const String religiousStudies = 'religious_studies';
  static const String science = 'science';

  /// A map associating faculty IDs with their human-readable names.
  static const Map<String, String> facultyMap = {
    artsAndHumanities: 'Faculty of Arts & Humanities',
    businessAdministration: 'Faculty of Business Administration',
    education: 'Faculty of Education',
    informationTechnology: 'Faculty of Information Technology',
    nursing: 'Faculty of Nursing',
    religiousStudies: 'Faculty of Religious Studies',
    science: 'Faculty of Science',
  };

  /// Retrieves the human-readable name of a faculty given its ID.
  /// Returns 'Unknown Faculty' if the ID is not found.
  static String getFacultyName(String id) {
    return facultyMap[id] ?? 'Unknown Faculty';
  }

  /// Retrieves the ID of a faculty given its human-readable name.
  /// Returns null if the name is not found.
  static String? getFacultyId(String name) {
    return facultyMap.entries
        .firstWhere(
          (entry) => entry.value == name,
          orElse: () =>
              const MapEntry('', null), // Return null value if not found
        )
        .key;
  }

  /// Returns a list of [MapEntry] for all faculties, suitable for UI dropdowns.
  static List<MapEntry<String, String>> get facultyList =>
      facultyMap.entries.toList();
}

/// Defines the structure for an exemplary (pre-defined) user.
class ExemplaryUser {
  final String username;
  final String email;
  final String password;
  final UserRole role;
  final String? facultyId;

  const ExemplaryUser({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.facultyId,
  });
}

/// Contains a list of pre-defined exemplary users for testing and demonstration.
/// These users can log in without going through the explicit sign-up process
/// as their accounts will be created automatically on first login if they don't exist.
class ExemplaryUsers {
  static const List<ExemplaryUser> list = [
    ExemplaryUser(
      username: 'Glad',
      email: 'glad@aiu.com',
      password: '0123456789',
      role: UserRole.admin,
      facultyId: AppFaculties.education,
    ),
    ExemplaryUser(
      username: 'Gladness',
      email: 'gladness@aiu.com',
      password: '0123456789',
      role: UserRole.user,
      facultyId: AppFaculties.informationTechnology,
    ),
    ExemplaryUser(
      username: 'Sisa',
      email: 'sisa@aiu.com',
      password: '0123456789',
      role: UserRole.user,
      facultyId: AppFaculties.businessAdministration,
    ),
    ExemplaryUser(
      username: 'Marie',
      email: 'marie@aiu.com',
      password: '0123456789',
      role: UserRole.user,
      facultyId: AppFaculties.science,
    ),
    ExemplaryUser(
      username: 'Lar',
      email: 'lar@aiu.com',
      password: '0123456789',
      role: UserRole.user,
      facultyId: AppFaculties.artsAndHumanities,
    ),
  ];

  /// Finds an [ExemplaryUser] by their email address.
  /// Returns null if no matching exemplary user is found.
  static ExemplaryUser? findByEmail(String email) {
    try {
      return list.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
}
