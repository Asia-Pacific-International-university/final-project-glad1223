// domain/entities/leaderboard_entry.dart

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int totalPoints; // Renamed 'score' to 'totalPoints' for clarity
  final double?
      accuracyPercentage; // New: (totalCorrectAnswers / totalQuestionsAttempted) * 100
  final int? participationCount; // New: totalParticipationEvents
  final int? bestSpeedMs; // New: fastestCompletionTimeMs
  final List<String> earnedBadges; // New: List of badge names/IDs

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.totalPoints,
    this.accuracyPercentage,
    this.participationCount,
    this.bestSpeedMs,
    this.earnedBadges = const [],
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      totalPoints: json['totalPoints'] as int,
      accuracyPercentage: json['accuracyPercentage'] as double?,
      participationCount: json['participationCount'] as int?,
      bestSpeedMs: json['bestSpeedMs'] as int?,
      earnedBadges: List<String>.from(json['earnedBadges'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'totalPoints': totalPoints,
      'accuracyPercentage': accuracyPercentage,
      'participationCount': participationCount,
      'bestSpeedMs': bestSpeedMs,
      'earnedBadges': earnedBadges,
    };
  }

  // Helper to convert from FacultyModel to LeaderboardEntry
  factory LeaderboardEntry.fromFacultyModel(FacultyModel faculty) {
    double? accuracy;
    if (faculty.totalQuestionsAttempted > 0) {
      accuracy =
          (faculty.totalCorrectAnswers / faculty.totalQuestionsAttempted) * 100;
    }
    return LeaderboardEntry(
      userId: faculty.id,
      userName: faculty.name,
      totalPoints: faculty.points,
      accuracyPercentage: accuracy,
      participationCount: faculty.totalParticipationEvents,
      bestSpeedMs: faculty.fastestCompletionTimeMs,
      earnedBadges: faculty.badges,
    );
  }
}
