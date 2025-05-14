import '../../domain/entities/user.dart';

class UserModel {
  final String? id;
  final String? username;
  final String? email;
  final String? faculty;
  final int? totalPoints;
  final List<String>? badges; // Assuming badges are just strings

  UserModel({
    this.id,
    this.username,
    this.email,
    this.faculty,
    this.totalPoints,
    this.badges,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      faculty: json['faculty'] as String?,
      totalPoints: json['totalPoints'] as int?,
      badges: (json['badges'] as List<dynamic>?)?.cast<String>(),
    );
  }

  User toDomain() {
    return User(
      id: id,
      username: username,
      email: email,
      faculty: faculty,
      totalPoints: totalPoints,
      badges: badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'faculty': faculty,
      'totalPoints': totalPoints,
      'badges': badges,
    };
  }
}
