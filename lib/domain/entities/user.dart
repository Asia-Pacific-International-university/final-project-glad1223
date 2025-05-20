import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart'; // For UserRole enum

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final UserRole role;
  final String? facultyId;
  final String? facultyName; // Derived from facultyId
  final int totalPoints; // Non-nullable
  final List<String> badges; // Non-nullable

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.facultyId,
    this.facultyName,
    this.totalPoints = 0, // Default to 0
    this.badges = const [], // Default to empty list
  });

  // copyWith method for immutability
  User copyWith({
    String? id,
    String? email,
    String? username,
    UserRole? role,
    String? facultyId,
    String? facultyName,
    int? totalPoints,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, username, role, facultyId, facultyName, totalPoints, badges];
}
