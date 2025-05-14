class LeaderboardEntry {
  final String? userId;
  final String? userName;
  final int? score;

  LeaderboardEntry({
    this.userId,
    this.userName,
    this.score,
  });

  // Optional: Add a factory method to create from a JSON object
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      score: json['score'] as int?,
    );
  }

  // Optional: Add a method to convert to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'score': score,
    };
  }
}
