class User {
  final String id;
  final String username;
  final String email;
  final String? faculty;
  final int? totalPoints;
  // Add other relevant user properties

  User({
    required this.id,
    required this.username,
    required this.email,
    this.faculty,
    this.totalPoints = 0,
  });

  // Optional: Factory method to create a basic user
  factory User.empty() {
    return User(id: '', username: '', email: '');
  }

  // Optional: Method to copy with new values
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? faculty,
    int? totalPoints,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
