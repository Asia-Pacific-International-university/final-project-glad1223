import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import '../services/quest_submission_service.dart'; // Import the submission service
import 'submit_quest_answer_usecase.dart'; // Import the abstract use case and params

// ========================================================================
// SUBMIT TRIVIA ANSWER USE CASE IMPLEMENTATION
// Orchestrates the submission of a trivia answer using the submission service.
// ========================================================================
class SubmitTriviaAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams> {
  // Dependency on the QuestSubmissionService
  final QuestSubmissionService _submissionService;

  SubmitTriviaAnswerUseCase({required QuestSubmissionService submissionService})
      : _submissionService = submissionService;

  @override
  Future<Either<Failure, QuestSubmissionResult>> call(SubmitTriviaAnswerParams params) async {
    // Call the submission service to process the trivia answer
    return await _submissionService.processTriviaSubmission(
      questId: params.questId,
      userId: params.userId,
      submittedAnswer: params.answer,
    );
  }
}
