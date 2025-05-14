class User {
  final String id;
  final String username;
  final String email;
  final String? faculty;
  final int? totalPoints;
  final List<String>? badges;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.faculty,
    this.totalPoints = 0,
    this.badges,
  });

  factory User.empty() {
    return User(id: '', username: '', email: '');
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? faculty,
    int? totalPoints,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
    );
  }
}
