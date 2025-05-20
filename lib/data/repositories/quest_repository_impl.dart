import 'package:dartz/dartz.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/quest_remote_datasource.dart';
import '../datasources/local/quest_local_datasource.dart'; // Import local data source
import '../models/quest_model.dart';

class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remoteDataSource;
  final QuestLocalDataSource _localDataSource; // Added local data source

  QuestRepositoryImpl({
    required QuestRemoteDataSource remoteDataSource,
    required QuestLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // Helper to save quest to local cache
  Future<void> _saveQuestToLocal(QuestModel? quest) async {
    if (quest != null) {
      await _localDataSource.saveQuest(quest);
    } else {
      // If quest is null, it means no active quest, so clear any cached active quest
      await _localDataSource
          .clearAllQuests(); // Or a more specific clearActiveQuest
    }
  }

  // Helper to get quest from local cache
  Future<QuestModel?> _getQuestFromLocal(String? questId) async {
    if (questId != null) {
      return await _localDataSource.getQuest(questId);
    }
    return await _localDataSource
        .getActiveQuest(); // Try to get the designated active quest
  }

  @override
  Future<Either<Failure, Quest?>> getActiveQuest() async {
    try {
      // 1. Try to get active quest from local cache first
      final cachedQuest = await _localDataSource.getActiveQuest();
      if (cachedQuest != null) {
        print('Returning active quest from local cache');
        return Right(cachedQuest.toDomain());
      }

      // 2. If not in cache or stale, fetch from remote
      print('Fetching active quest from remote source');
      final questModel = await _remoteDataSource.getActiveQuest();

      // 3. Save to local cache
      await _saveQuestToLocal(questModel);

      if (questModel == null) {
        print('No active quest found remotely.');
        return const Right(null); // No active quest is a valid success case
      }
      print('Returning active quest from remote source and cached locally');
      return Right(questModel.toDomain());
    } on Exception catch (e) {
      print('getActiveQuest Exception: $e');
      // If remote fetch fails, try to return from cache as fallback
      final cachedQuest = await _localDataSource.getActiveQuest();
      if (cachedQuest != null) {
        print(
            'Remote fetch failed, returning cached active quest as fallback.');
        return Right(cachedQuest.toDomain());
      }
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
      // No need to cache individual answers, as they are sent to backend.
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
      return const Right(null);
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

  // TODO: Implement submitMiniPuzzleAnswer if QuestRemoteDataSource has it
  // @override
  // Future<Either<Failure, void>> submitMiniPuzzleAnswer(String questId, String answer) async {
  //   try {
  //     await _remoteDataSource.submitMiniPuzzleAnswer(questId, answer);
  //     return const Right(null);
  //   } on Exception catch (e) {
  //     print('submitMiniPuzzleAnswer Exception: $e');
  //     return Left(ServerFailure('Failed to submit mini-puzzle answer: ${e.toString()}'));
  //   }
  // }
}
