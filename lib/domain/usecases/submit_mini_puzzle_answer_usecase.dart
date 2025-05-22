import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
//import '../../core/usecases/usecase.dart';
import 'package:final_project/domain/services/quest_submision_service.dart';
import 'submit_quest_answer_usecase.dart'; // Keep this import for the abstract base class

// THIS IS THE ONLY PLACE SubmitMiniPuzzleAnswerParams SHOULD BE DEFINED
class SubmitMiniPuzzleAnswerParams {
  final String questId;
  final String
      puzzleAnswer; // Renamed to puzzleAnswer as per your original error message
  final String userId;

  SubmitMiniPuzzleAnswerParams({
    required this.questId,
    required this.puzzleAnswer, // Match the field name
    required this.userId,
  });
}

class SubmitMiniPuzzleAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams> {
  final QuestSubmissionService submissionService;

  SubmitMiniPuzzleAnswerUseCase({required this.submissionService});

  @override
  Future<Either<Failure, SubmissionResult>> call(
      SubmitMiniPuzzleAnswerParams params) async {
    return await submissionService.submitMiniPuzzleAnswer(
      questId: params.questId,
      userId: params.userId,
      answer: params.puzzleAnswer, // Pass puzzleAnswer to the service method
    );
  }
}
