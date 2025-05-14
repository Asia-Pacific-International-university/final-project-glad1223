import 'package:final_project/domain/entities/user.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/domain/entities/leaderboard_entry.dart';
import 'package:final_project/domain/entities/quest.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUp(
      String email, String password, String faculty);
  Future<Either<Failure, User>> signIn(String email, String password);
  // Add other auth-related methods
}

abstract class LeaderboardRepository {
  Stream<List<LeaderboardEntry>> getLeaderboardStream();
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboardSnapshot();
}

abstract class QuestRepository {
  Future<Either<Failure, Quest?>> getActiveQuest();
  Future<Either<Failure, void>> submitTriviaAnswer(
      String questId, String answer);
  Future<Either<Failure, void>> submitPollVote(String questId, String optionId);
  Future<Either<Failure, void>> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<Either<Failure, String>> uploadPhoto(String questId, String imagePath);
  // Add other quest-related methods
}

abstract class UserRepository {
  // Add user-related repository methods
}
