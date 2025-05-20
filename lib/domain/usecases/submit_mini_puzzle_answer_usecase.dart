import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../services/quest_submission_service.dart'; // Import SubmissionResult

class SubmitMiniPuzzleAnswerUseCase
    implements UseCase<SubmissionResult, SubmitMiniPuzzleAnswerParams> {
  final QuestSubmissionService submissionService;

  SubmitMiniPuzzleAnswerUseCase({required this.submissionService});

  @override
  Future<Either<Failure, SubmissionResult>> call(
      SubmitMiniPuzzleAnswerParams params) async {
    return await submissionService.submitMiniPuzzleAnswer(
      questId: params.questId,
      answer: params.answer,
      userId: params.userId,
    );
  }
}

class SubmitMiniPuzzleAnswerParams {
  final String questId;
  final String answer; // Generic answer for mini-puzzle
  final String userId;

  SubmitMiniPuzzleAnswerParams({
    required this.questId,
    required this.answer,
    required this.userId,
  });
}
