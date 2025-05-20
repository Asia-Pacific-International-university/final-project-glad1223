// domain/repositories/leaderboard_repositories.dart
import 'package:dartz/dartz.dart';
import '../entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';
import 'dart:async'; // Add this import

abstract class LeaderboardRepositories {
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream();
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard();
  // Optional: Add new methods for specific leaderboards
  Stream<Either<Failure, List<LeaderboardEntry>>> getFastestLeaderboardStream();
  Future<Either<Failure, List<LeaderboardEntry>>>
      getAccuracyLeaderboardSnapshot();
}
