import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import '../services/quest_submision_service.dart'; // Import the submission service
import 'submit_quest_answer_usecase.dart'; // Import the abstract use case and QuestSubmissionResult

// Define the parameter class for Trivia Answer submission
class SubmitTriviaAnswerParams {
  final String questId;
  final String userId;
  final String answer; // The submitted answer for the trivia question

  SubmitTriviaAnswerParams({
    required this.questId,
    required this.userId,
    required this.answer,
  });
}

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
  Future<Either<Failure, QuestSubmissionResult>> call(
      SubmitTriviaAnswerParams params) async {
    // Call the submission service to process the trivia answer
    return await _submissionService.processTriviaSubmission(
      questId: params.questId,
      userId: params.userId,
      submittedAnswer: params.answer,
    );
  }
}
