import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/repositories/user_repositories.dart'; // Import UserRepository
//import '../../domain/entities/user.dart'; // Import User entity

// Represents the outcome of a quest submission
class SubmissionResult {
  final bool isSuccessful;
  final int pointsEarned;
  final String feedbackMessage;
  final List<String> newBadges; // Badges earned in this submission

  SubmissionResult({
    required this.isSuccessful,
    this.pointsEarned = 0,
    this.feedbackMessage = '',
    this.newBadges = const [],
  });
}

// ========================================================================
// QUEST SUBMISSION SERVICE
// Handles the business logic for submitting quest answers,
// validating, scoring, and updating user data.
// This service coordinates between QuestRepository and UserRepository.
// ========================================================================
class QuestSubmissionService {
  final QuestRepository _questRepository;
  final UserRepository _userRepository; // Added UserRepository

  QuestSubmissionService({
    required QuestRepository questRepository,
    required UserRepository userRepository, // Initialize UserRepository
  })  : _questRepository = questRepository,
        _userRepository = userRepository;

  // Generic method to handle post-submission updates (points, badges)
  Future<Either<Failure, SubmissionResult>> _handleSubmissionResponse({
    required String userId,
    required Either<Failure, dynamic>
        submissionResult, // dynamic can be String (for photo/trivia URL/msg) or void
    required int basePoints,
    required String successMessage,
    required String failureMessage,
    int? speedBonus, // Optional speed bonus
  }) async {
    return submissionResult.fold(
      (failure) => Left(failure),
      (data) async {
        // Assume `data` indicates success.
        // In a real backend, this `data` might contain points awarded,
        // but for now, we'll use a fixed `basePoints` and `speedBonus`.

        int totalPointsEarned = basePoints + (speedBonus ?? 0);

        // 1. Update user's total points
        final userUpdateResult = await _userRepository.updateUserTotalPoints(
          userId,
          totalPointsEarned, // This will be added to existing points by the repo
        );

        return userUpdateResult.fold(
          (failure) =>
              Left(failure), // If updating user fails, return that failure
          (updatedUser) {
            // 2. Check for new badges after points update
            final List<String> earnedBadges =
                _checkForNewBadges(updatedUser.totalPoints, updatedUser.badges);

            // 3. Add any newly earned badges to the user's profile
            if (earnedBadges.isNotEmpty) {
              _userRepository.addUserBadges(updatedUser.id, earnedBadges);
              // Note: The UI will get the updated user via stream/re-fetch.
            }

            return Right(SubmissionResult(
              isSuccessful: true,
              pointsEarned: totalPointsEarned,
              feedbackMessage: successMessage,
              newBadges: earnedBadges,
            ));
          },
        );
      },
    );
  }

  // Helper to check for new badges based on total points
  List<String> _checkForNewBadges(
      int currentTotalPoints, List<String> existingBadges) {
    final List<String> newBadges = [];
    if (currentTotalPoints >= 10 &&
        !existingBadges.contains('Good Job. Beginner Badge')) {
      newBadges.add('Good Job. Beginner Badge');
    }
    if (currentTotalPoints >= 50 &&
        !existingBadges.contains('Great Job. Master Badge')) {
      newBadges.add('Great Job. Master Badge');
    }
    if (currentTotalPoints >= 100 &&
        !existingBadges.contains('Best Job. Pro Badge')) {
      newBadges.add('Best Job. Pro Badge');
    }
    return newBadges;
  }

  // --- Specific Quest Submission Methods ---

  Future<Either<Failure, SubmissionResult>> submitTriviaAnswer({
    required String questId,
    required String answer,
    required String userId,
    int? speedBonus,
  }) async {
    final result = await _questRepository.submitTriviaAnswer(questId, answer);
    return _handleSubmissionResponse(
      userId: userId,
      submissionResult: result,
      basePoints: 10, // Example base points for trivia
      successMessage: 'Trivia answer submitted successfully!',
      failureMessage: 'Failed to submit trivia answer.',
      speedBonus: speedBonus,
    );
  }

  Future<Either<Failure, SubmissionResult>> submitPollVote({
    required String questId,
    required String optionId,
    required String userId,
  }) async {
    final result = await _questRepository.submitPollVote(questId, optionId);
    return _handleSubmissionResponse(
      userId: userId,
      submissionResult: result,
      basePoints: 5, // Example base points for poll participation
      successMessage: 'Poll vote submitted!',
      failureMessage: 'Failed to submit poll vote.',
    );
  }

  Future<Either<Failure, SubmissionResult>> submitLocationCheckIn({
    required String questId,
    required double latitude,
    required double longitude,
    required String userId,
    int? speedBonus,
  }) async {
    final result = await _questRepository.submitCheckInLocation(
        questId, latitude, longitude);
    return _handleSubmissionResponse(
      userId: userId,
      submissionResult: result,
      basePoints: 15, // Example base points for location check-in
      successMessage: 'Location checked in successfully!',
      failureMessage: 'Failed to check-in location.',
      speedBonus: speedBonus,
    );
  }

  Future<Either<Failure, SubmissionResult>> submitPhotoChallenge({
    required String questId,
    required String imagePath,
    required String userId,
    int? speedBonus,
  }) async {
    final result = await _questRepository.uploadPhoto(questId, imagePath);
    return _handleSubmissionResponse(
      userId: userId,
      submissionResult: result,
      basePoints: 20, // Example base points for photo challenge
      successMessage: 'Photo submitted successfully!',
      failureMessage: 'Failed to upload photo.',
      speedBonus: speedBonus,
    );
  }

  Future<Either<Failure, SubmissionResult>> submitMiniPuzzleAnswer({
    required String questId,
    required String answer,
    required String userId,
    int? speedBonus,
  }) async {
    // This method would call a new method on QuestRepository for mini-puzzle submission
    // For now, we'll simulate a submission result.
    // In a real scenario, you'd have:
    // final result = await _questRepository.submitMiniPuzzleAnswer(questId, answer);
    // return _handleSubmissionResponse(...)
    print(
        'Simulating mini-puzzle submission for quest $questId with answer $answer');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // For demonstration, let's assume it's always successful for now
    // The fix is here: Explicitly define the Left type as Failure.
    final Either<Failure, String> mockResult = Right('Puzzle solved!');

    return _handleSubmissionResponse(
      userId: userId,
      submissionResult: mockResult,
      basePoints: 25, // Example base points for mini-puzzle
      successMessage: 'Mini-puzzle solved!',
      failureMessage: 'Failed to solve mini-puzzle.',
      speedBonus: speedBonus,
    );
  }
}
