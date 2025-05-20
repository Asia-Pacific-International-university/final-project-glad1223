import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/quest.dart';

abstract class QuestRepository {
  Future<Either<Failure, Quest?>> getActiveQuest();
  Future<Either<Failure, String>> submitTriviaAnswer(
      String questId, String answer);
  Future<Either<Failure, void>> submitPollVote(
      String questId, String optionId); // Added
  Future<Either<Failure, void>> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<Either<Failure, String>> uploadPhoto(String questId, String imagePath);
  Future<Either<Failure, void>> submitMiniPuzzleAnswer(
      String questId, String answer); // Added
}
