import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardModel {
  final String? userId;
  final String? userName;
  final int? score;

  LeaderboardModel({
    this.userId,
    this.userName,
    this.score,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      score: json['score'] as int?,
    );
  }

  LeaderboardEntry toDomain() {
    return LeaderboardEntry(
      userId: userId,
      userName: userName,
      score: score,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'score': score,
    };
  }
}
