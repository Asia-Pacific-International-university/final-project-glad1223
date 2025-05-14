import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/domain/repositories/user_repository.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ProcessQuestSubmissionUseCase
    implements FutureUseCase<void, ProcessQuestSubmissionParams> {
  final QuestRepository _questRepository;
  final UserRepository _userRepository; // Example: to update user points

  ProcessQuestSubmissionUseCase(
      {required questRepository, required userRepository})
      : _questRepository = questRepository,
        _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> execute(
      ProcessQuestSubmissionParams params) async {
    // 1. Submit the answer to the quest repository
    final submissionResult = await _questRepository.submitTriviaAnswer(
        params.questId, params.answer);
    return submissionResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. If submission is successful, update user points (example)
        // final updateResult = await _userRepository.addPoints(params.userId, params.pointsAwarded);
        // return updateResult; // Assuming userRepository.addPoints returns Either<Failure, void>
        return const Right(null); // If no user update needed here
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
