import 'package:final_project/domain/entities/leaderboard_entry.dart';

class Leaderboard {
  final DateTime lastUpdated;
  final List<LeaderboardEntry> entries;

  Leaderboard({required this.lastUpdated, required this.entries});
}
