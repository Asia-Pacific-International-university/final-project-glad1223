import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/domain/repositories/user_repositories.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ProcessQuestSubmissionUseCase
    implements ParamFutureUseCase<void, ProcessQuestSubmissionParams> {
  // Corrected implements clause
  final QuestRepository _questRepository;
  final UserRepositories _userRepository; // Example: to update user points

  ProcessQuestSubmissionUseCase(
      {required QuestRepository questRepository,
      required UserRepositories
          userRepository}) // Corrected constructor parameters
      : _questRepository = questRepository,
        _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(
      ProcessQuestSubmissionParams params) async {
    // 1. Submit the answer to the quest repository
    final submissionResult = await _questRepository.submitTriviaAnswer(
        params.questId, params.answer);
    return submissionResult.fold(
      (failure) => Left(failure),
      (success) async {
        // Added async here
        // 2. If submission is successful, update user points (example)
        try {
          // added try-catch
          final updateResult = await _userRepository.addPoints(
              params.userId, params.pointsAwarded);
          return updateResult; // Assuming userRepository.addPoints returns Either<Failure, void>
        } catch (e) {
          return Left(
              ServerFailure('Failed to update points: $e')); // convert error.
        }
      },
    );
  }
}

class ProcessQuestSubmissionParams {
  final String questId;
  final String answer;
  final String userId;
  final int pointsAwarded;

  ProcessQuestSubmissionParams(
      {required this.questId,
      required this.answer,
      required this.userId,
      required this.pointsAwarded});
}
