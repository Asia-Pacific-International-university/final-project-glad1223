import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../services/quest_submission_service.dart'; // Import SubmissionResult

class SubmitPollVoteUseCase
    implements UseCase<SubmissionResult, SubmitPollVoteParams> {
  final QuestSubmissionService submissionService;

  SubmitPollVoteUseCase({required this.submissionService});

  @override
  Future<Either<Failure, SubmissionResult>> call(
      SubmitPollVoteParams params) async {
    return await submissionService.submitPollVote(
      questId: params.questId,
      optionId: params.optionId,
      userId: params.userId,
    );
  }
}

class SubmitPollVoteParams {
  final String questId;
  final String optionId;
  final String userId;

  SubmitPollVoteParams({
    required this.questId,
    required this.optionId,
    required this.userId,
  });
}
