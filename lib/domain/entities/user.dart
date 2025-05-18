// lib/domain/entities/user.dart

import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart'; // Import the role enum

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? facultyId; // Use facultyId to align with backend/data layer
  final String? facultyName; // Optional display name for faculty
  final int? totalPoints;
  final List<String>? badges;
  final UserRole role; // Make role non-nullable and provide a default

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.facultyId,
    this.facultyName,
    this.totalPoints = 0,
    this.badges = const [], // Provide a default empty list
    this.role = UserRole.user, // Include in constructor with a default value
  });

  factory User.empty() {
    return const User(id: '', username: '', email: '');
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? facultyId,
    String? facultyName,
    int? totalPoints,
    List<String>? badges,
    UserRole? role, // Make nullable in copyWith
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      role: role ?? this.role, // Use nullable value from copyWith
    );
  }

  @override
  List<Object?> get props =>
      [id, username, email, facultyId, facultyName, totalPoints, badges, role];
}


// class User {
//   final String id;
//   final String username;
//   final String email;
//   final String? faculty;
//   final int? totalPoints;
//   final List<String>? badges;

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     this.faculty,
//     this.totalPoints = 0,
//     this.badges,
//   });

//   factory User.empty() {
//     return User(id: '', username: '', email: '');
//   }

//   User copyWith({
//     String? id,
//     String? username,
//     String? email,
//     String? faculty,
//     int? totalPoints,
//     List<String>? badges,
//   }) {
//     return User(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       faculty: faculty ?? this.faculty,
//       totalPoints: totalPoints ?? this.totalPoints,
//       badges: badges ?? this.badges,
//     );
//   }
// }
// 