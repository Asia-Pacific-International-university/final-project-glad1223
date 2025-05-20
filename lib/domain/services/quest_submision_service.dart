import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Assuming Failure classes are defined here
import '../entities/quest.dart'; // Assuming Quest entity is defined here
// You'll need a repository or data source to interact with the backend
import '../../data/repositories/quest_repository_impl.dart'; // Assuming you have this implementation

// ========================================================================
// QUEST SUBMISSION SERVICE
// Handles the business logic related to submitting quest answers
// and updating user/faculty performance.
// ========================================================================
class QuestSubmissionService {
  // Dependency on a repository that handles data persistence/backend calls
  final QuestRepositoryImpl _questRepository;
  // You might also need a service to update user/faculty points and badges
  // final FacultyPerformanceService _facultyPerformanceService; // Example

  QuestSubmissionService(
      this._questRepository /*, this._facultyPerformanceService*/);

  // --- Helper method to process backend results and update local state/profile ---
  // This method encapsulates the logic that happens AFTER a successful backend submission.
  Future<Either<Failure, QuestSubmissionResult>> _processBackendResult(
      Either<Failure, SubmissionSuccessResponse> backendResult,
      String userId) async {
    return backendResult.fold(
      (failure) => Left(failure), // Pass backend failure through
      (successResponse) {
        // TODO: Implement updating user/faculty performance based on successResponse
        // This is CRITICAL for points and badges to reflect.
        // successResponse might contain points earned, whether correct, new badges, etc.
        // Example:
        // _facultyPerformanceService.updateUserPoints(userId, successResponse.pointsEarned);
        // _facultyPerformanceService.awardBadges(userId, successResponse.newBadges);
        print(
            "QuestSubmissionService: Backend success! Points: ${successResponse.pointsEarned}, Badges: ${successResponse.newBadges}");

        // Return a result object that the UI can use
        return Right(QuestSubmissionResult(
          isSuccessful: successResponse
              .isCorrect, // Assuming backend tells us if correct/valid/accepted
          pointsEarned:
              successResponse.pointsEarned, // Assuming backend provides points
          feedbackMessage: successResponse
              .feedbackMessage, // Assuming backend provides feedback
          newBadges:
              successResponse.newBadges, // Assuming backend provides new badges
        ));
      },
    );
  }

  // Method to process a trivia quest submission
  Future<Either<Failure, QuestSubmissionResult>> processTriviaSubmission({
    required String questId,
    required String userId,
    required String submittedAnswer,
  }) async {
    try {
      // Call the repository to submit the answer to the backend
      // The backend should handle validation, scoring, and updating user/faculty data
      final backendResult = await _questRepository.submitTriviaAnswer(
          questId, userId, submittedAnswer);

      // Process the result from the backend and update local state/profile
      return _processBackendResult(backendResult, userId);
    } on Failure catch (e) {
      // Catch specific failures from repository or validation
      return Left(e);
    } catch (e) {
      // Catch any unexpected errors
      return Left(ServerFailure(
          message: 'Failed to process trivia submission: ${e.toString()}'));
    }
  }

  // Method to process a location check-in submission
  Future<Either<Failure, QuestSubmissionResult>>
      processLocationCheckInSubmission({
    required String questId,
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Call the repository to submit the location to the backend
      final backendResult = await _questRepository.submitCheckInLocation(
          questId, userId, latitude, longitude);

      // Process the result from the backend and update local state/profile
      return _processBackendResult(backendResult, userId);
    } on Failure catch (e) {
      // Catch specific failures from repository or validation
      return Left(e);
    } catch (e) {
      // Catch any unexpected errors
      return Left(ServerFailure(
          message:
              'Failed to process location check-in submission: ${e.toString()}'));
    }
  }

  // Method to process a photo challenge submission
  Future<Either<Failure, QuestSubmissionResult>>
      processPhotoChallengeSubmission({
    required String questId,
    required String userId,
    required String imagePath, // Path to the local image file
  }) async {
    try {
      // Call the repository to upload the photo and submit the challenge
      final backendResult = await _questRepository.uploadPhotoForChallenge(
          questId, userId, imagePath);

      // Process the result from the backend and update local state/profile
      return _processBackendResult(backendResult, userId);
    } on Failure catch (e) {
      // Catch specific failures from repository or upload
      return Left(e);
    } catch (e) {
      // Catch any unexpected errors
      return Left(ServerFailure(
          message:
              'Failed to process photo challenge submission: ${e.toString()}'));
    }
  }

  // TODO: Add methods for other quest types (Poll, Mini-Puzzle)
  Future<Either<Failure, QuestSubmissionResult>> processPollSubmission({
    required String questId,
    required String userId,
    required String selectedOptionId,
  }) async {
    try {
      // Call the repository to submit the poll vote
      final backendResult = await _questRepository.submitPollVote(
          questId, userId, selectedOptionId);

      // Process the result from the backend and update local state/profile
      return _processBackendResult(backendResult, userId);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to process poll submission: ${e.toString()}'));
    }
  }

  Future<Either<Failure, QuestSubmissionResult>> processMiniPuzzleSubmission({
    required String questId,
    required String userId,
    required String puzzleAnswer, // Or a more complex answer type
  }) async {
    try {
      // Call the repository to submit the puzzle answer
      final backendResult = await _questRepository.submitMiniPuzzleAnswer(
          questId, userId, puzzleAnswer);

      // Process the result from the backend and update local state/profile
      return _processBackendResult(backendResult, userId);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(
          message:
              'Failed to process mini-puzzle submission: ${e.toString()}'));
    }
  }
}

// ========================================================================
// HELPER CLASSES (Ensure these match your project structure)
// Assuming these are defined in your project:
// core/error/failures.dart
// domain/entities/quest.dart
// data/repositories/quest_repository_impl.dart (needs methods matching service calls)
// ========================================================================

// Example Failure classes (ensure these match your core/error/failures.dart)
// abstract class Failure {
//   final String message;
//   const Failure({required this.message});
// }
// class ServerFailure extends Failure { const ServerFailure({String? message}) : super(message: message ?? 'Server Error'); }
// class IncorrectAnswerFailure extends Failure { const IncorrectAnswerFailure({required String message}) : super(message: message); }
// class UnexpectedFailure extends Failure { const UnexpectedFailure({String? message}) : super(message: message ?? 'Unexpected Error'); }

// Example success response structure from backend (Adjust based on your actual API)
// This is what your QuestRepository methods would return on success.
class SubmissionSuccessResponse {
  final bool isCorrect; // or isValidCheckIn, isAccepted, isSolved etc.
  final int pointsEarned;
  final String feedbackMessage;
  final List<String> newBadges;

  SubmissionSuccessResponse({
    required this.isCorrect,
    required this.pointsEarned,
    required this.feedbackMessage,
    this.newBadges = const [],
  });
}

// Example result structure returned by the service methods to the UseCase/Presentation
class QuestSubmissionResult {
  final bool isSuccessful;
  final int pointsEarned;
  final String feedbackMessage;
  final List<String> newBadges;

  QuestSubmissionResult({
    required this.isSuccessful,
    required this.pointsEarned,
    required this.feedbackMessage,
    this.newBadges = const [],
  });
}

// Example Abstract QuestRepository (ensure this matches your domain/repositories/quest_repository.dart)
// This repository needs methods that the service can call.
abstract class QuestRepository {
  // Method to get the active quest
  Future<Either<Failure, Quest?>> getActiveQuest();

  // Submission methods - they return the backend's raw success response or a Failure
  Future<Either<Failure, SubmissionSuccessResponse>> submitTriviaAnswer(
      String questId, String userId, String answer);
  Future<Either<Failure, SubmissionSuccessResponse>> submitPollVote(
      String questId, String userId, String optionId); // Added userId
  Future<Either<Failure, SubmissionSuccessResponse>> submitCheckInLocation(
      String questId,
      String userId,
      double latitude,
      double longitude); // Added userId
  Future<Either<Failure, SubmissionSuccessResponse>> uploadPhotoForChallenge(
      String questId, String userId, String imagePath); // Added userId
  Future<Either<Failure, SubmissionSuccessResponse>> submitMiniPuzzleAnswer(
      String questId, String userId, String puzzleAnswer); // Added userId
  // Add other quest type submission methods if needed
}

// Example Quest Entity (ensure this matches your domain/entities/quest.dart)
// This is a simplified version just for the service to compile
enum QuestType { trivia, poll, locationCheckIn, photoChallenge, miniPuzzle }

class Quest {
  final String id;
  final QuestType type;
  final String title;
  final String? description;
  final Duration? duration; // Added duration for timer
  // Add other quest properties as needed by the service (e.g., options for poll)
  // final List<String>? options; // Example for Poll
  // final String? correctAnswer; // Example for Trivia validation (if client-side)

  Quest({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.duration,
    // this.options,
    // this.correctAnswer,
  });
}
