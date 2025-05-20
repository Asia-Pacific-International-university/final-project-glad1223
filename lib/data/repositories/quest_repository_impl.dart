import 'package:dartz/dartz.dart';
import 'package:final_project/core/error/failures.dart';
// import 'package:final_project/core/error/exceptions.dart'; // If you have custom exceptions like ServerException
import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
// Make sure your QuestModel has a toDomain() method
// import 'package:final_project/data/models/quest_model.dart';

class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remoteDataSource;

  QuestRepositoryImpl({required QuestRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Quest?>> getActiveQuest() async {
    try {
      final questModel = await _remoteDataSource.getActiveQuest();
      if (questModel == null) {
        return const Right(null); // No active quest is a valid success case
      }
      return Right(questModel.toDomain()); // Assuming QuestModel has toDomain()
    } on Exception catch (e) {
      // Catch generic Exception or specific ones
      // Log the exception e for debugging
      print('getActiveQuest Exception: $e');
      return Left(
          ServerFailure('Failed to load active quest: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> submitTriviaAnswer(
      String questId, String answer) async {
    try {
      final resultMessage =
          await _remoteDataSource.submitTriviaAnswer(questId, answer);
      return Right(resultMessage);
    } on Exception catch (e) {
      print('submitTriviaAnswer Exception: $e');
      return Left(
          ServerFailure('Failed to submit trivia answer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitPollVote(
      String questId, String optionId) async {
    try {
      await _remoteDataSource.submitPollVote(questId, optionId);
      return const Right(
          null); // Using Right(null) for Future<Either<Failure, void>>
    } on Exception catch (e) {
      print('submitPollVote Exception: $e');
      return Left(ServerFailure('Failed to submit poll vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitCheckInLocation(
      String questId, double latitude, double longitude) async {
    try {
      await _remoteDataSource.submitCheckInLocation(
          questId, latitude, longitude);
      return const Right(null);
    } on Exception catch (e) {
      print('submitCheckInLocation Exception: $e');
      return Left(ServerFailure('Failed to submit location: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(
      String questId, String imagePath) async {
    try {
      final imageUrl = await _remoteDataSource.uploadPhoto(questId, imagePath);
      return Right(imageUrl);
    } on Exception catch (e) {
      print('uploadPhoto Exception: $e');
      return Left(ServerFailure('Failed to upload photo: ${e.toString()}'));
    }
  }
}
