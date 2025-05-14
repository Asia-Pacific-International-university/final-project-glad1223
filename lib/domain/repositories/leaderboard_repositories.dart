import 'package:dartz/dartz.dart';
import '../entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';

abstract class LeaderboardRepositories {
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream();
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard();
}
