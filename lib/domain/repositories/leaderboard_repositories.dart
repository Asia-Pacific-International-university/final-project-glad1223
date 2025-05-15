// lib/domain/repositories/leaderboard_repositories.dart
import 'package:dartz/dartz.dart';
import '../entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';

abstract class LeaderboardRepositories {
  // Corrected abstract class name
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream();
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard();
}
