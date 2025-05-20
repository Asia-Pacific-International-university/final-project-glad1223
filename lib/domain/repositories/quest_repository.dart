import 'package:dartz/dartz.dart';
import 'package:final_project/core/error/failures.dart'; // Ensure this path is correct
import 'package:final_project/domain/entities/quest.dart'; // Ensure this path is correct

abstract class QuestRepository {
  Future<Either<Failure, Quest?>> getActiveQuest();
  Future<Either<Failure, String>> submitTriviaAnswer(
      String questId, String answer); // Returns Either
  Future<Either<Failure, void>> submitPollVote(String questId, String optionId);
  Future<Either<Failure, void>> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<Either<Failure, String>> uploadPhoto(String questId, String imagePath);
  // Add other quest type submission methods if needed
}
