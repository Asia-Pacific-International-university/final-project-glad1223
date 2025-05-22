import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart'; // Import the logger package
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/quest_remote_datasource.dart';
import '../datasources/local/quest_local_datasource.dart'; // Import local data source
import '../models/quest_model.dart';

class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remoteDataSource;
  final QuestLocalDataSource _localDataSource; // Added local data source
  // Initialize a logger instance for this class
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1, // Show one method call for context
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print emojis
      printTime: false, // Should each log print a timestamp
    ),
  );

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
        _logger.i('Returning active quest from local cache');
        return Right(cachedQuest.toDomain());
      }

      // 2. If not in cache or stale, fetch from remote
      _logger.i('Fetching active quest from remote source');
      final questModel = await _remoteDataSource.getActiveQuest();

      // 3. Save to local cache
      await _saveQuestToLocal(questModel);

      if (questModel == null) {
        _logger.i('No active quest found remotely.');
        return const Right(null); // No active quest is a valid success case
      }
      _logger.i('Returning active quest from remote source and cached locally');
      return Right(questModel.toDomain());
    } on Exception catch (e) {
      _logger.e('getActiveQuest Exception: $e', e);
      // If remote fetch fails, try to return from cache as fallback
      final cachedQuest = await _localDataSource.getActiveQuest();
      if (cachedQuest != null) {
        _logger.w(
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
      _logger.i('Trivia answer submitted successfully for quest $questId');
      return Right(resultMessage);
    } on Exception catch (e) {
      _logger.e('submitTriviaAnswer Exception: $e', e);
      return Left(
          ServerFailure('Failed to submit trivia answer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitPollVote(
      String questId, String optionId) async {
    try {
      await _remoteDataSource.submitPollVote(questId, optionId);
      _logger.i('Poll vote submitted successfully for quest $questId');
      return const Right(null);
    } on Exception catch (e) {
      _logger.e('submitPollVote Exception: $e', e);
      return Left(ServerFailure('Failed to submit poll vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitCheckInLocation(
      String questId, double latitude, double longitude) async {
    try {
      await _remoteDataSource.submitCheckInLocation(
          questId, latitude, longitude);
      _logger.i('Check-in location submitted successfully for quest $questId');
      return const Right(null);
    } on Exception catch (e) {
      _logger.e('submitCheckInLocation Exception: $e', e);
      return Left(ServerFailure('Failed to submit location: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(
      String questId, String imagePath) async {
    try {
      final imageUrl = await _remoteDataSource.uploadPhoto(questId, imagePath);
      _logger
          .i('Photo uploaded successfully for quest $questId. URL: $imageUrl');
      return Right(imageUrl);
    } on Exception catch (e) {
      _logger.e('uploadPhoto Exception: $e', e);
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
  //     _logger.e('submitMiniPuzzleAnswer Exception: $e', e);
  //     return Left(ServerFailure('Failed to submit mini-puzzle answer: ${e.toString()}'));
  //   }
  // }
}
