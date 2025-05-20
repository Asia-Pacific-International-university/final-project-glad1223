import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String username,
    String? facultyId, // Nullable from JSON
    int? totalPoints, // Nullable from JSON
    List<String>? badges, // Nullable from JSON
    required UserRole role,
  }) : super(
          id: id,
          email: email,
          username: username,
          role: role,
          facultyId: facultyId,
          facultyName: facultyId != null
              ? AppFaculties.getFacultyName(facultyId)
              : null, // Map ID to Name for User entity, handle null
          totalPoints: totalPoints ?? 0, // Default to 0 if null
          badges: badges ?? const [], // Default to empty list if null
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final UserRole parsedRole =
        userRoleFromString(json['role'] as String?) ?? UserRole.user;
    final String? facultyId = json['facultyId'] as String?;

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      facultyId: facultyId,
      totalPoints: json['totalPoints'] as int?,
      badges: (json['badges'] as List<dynamic>?)?.cast<String>(),
      role: parsedRole,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'facultyId': facultyId,
      'totalPoints': totalPoints,
      'badges': badges,
      'role': role.name,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      facultyId: user.facultyId,
      totalPoints: user.totalPoints,
      badges: user.badges,
      role: user.role,
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      username: username,
      facultyId: facultyId,
      facultyName: facultyName,
      totalPoints: totalPoints,
      badges: badges,
      role: role,
    );
  }
}
