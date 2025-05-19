// lib/data/models/user_model.dart

import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';

class UserModel extends User {
  // UserModel now directly provides the data needed by User entity constructor

  const UserModel({
    required String id,
    required String email, // Add email
    required String username,
    required String?
        facultyId, // Made nullable to handle potential null from JSON
    required int?
        totalPoints, // Made nullable to handle potential null from JSON
    required List<String>?
        badges, // Made nullable to handle potential null from JSON
    required UserRole? role, // Made nullable to handle potential null from JSON
  }) : super(
          // Pass data to User entity constructor
          id: id,
          email: email,
          username: username,
          facultyId: facultyId, // Pass ID to User entity
          facultyName: facultyId != null
              ? AppFaculties.getFacultyName(facultyId)
              : null, // Map ID to Name for User entity, handle null
          totalPoints: totalPoints ?? 0,
          badges: badges ?? const [],
          role: role ?? UserRole.user,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final UserRole parsedRole =
        userRoleFromString(json['role'] as String?) ?? UserRole.user;
    final String? facultyId = json['facultyId'] as String?; // Read ID from JSON

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '', // Read email from JSON
      username: json['username'] as String? ?? '',
      facultyId: facultyId,
      totalPoints: json['totalPoints'] as int?,
      badges: (json['badges'] as List<dynamic>?)?.cast<String>(),
      role: parsedRole,
    );
  }

  // toJson uses the fields inherited from User, including facultyId
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'facultyId': facultyId, // Use the facultyId from the User entity part
      'totalPoints': totalPoints,
      'badges': badges,
      'role': role.name,
    };
  }

  // fromEntity is now feasible if you needed it elsewhere
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      facultyId: user.facultyId, // Use ID from entity
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
      facultyName:
          facultyId != null ? AppFaculties.getFacultyName(facultyId) : null,
      totalPoints: totalPoints,
      badges: badges,
      role: role,
    );
  }
}
