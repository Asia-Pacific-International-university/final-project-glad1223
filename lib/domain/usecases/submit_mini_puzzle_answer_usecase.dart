import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Ensure Failure is defined here
//import '../../core/usecases/usecase.dart'; // Ensure UseCase is defined here
import 'package:final_project/domain/services/quest_submision_service.dart'; // For QuestSubmissionService and QuestSubmissionResult
import 'submit_quest_answer_usecase.dart'; // Import the abstract base class for quest answers

// Define the parameter class for Mini Puzzle Answer submission
class SubmitMiniPuzzleAnswerParams {
  final String questId;
  final String answer; // The submitted answer for the mini puzzle
  final String userId;

  SubmitMiniPuzzleAnswerParams({
    required this.questId,
    required this.answer,
    required this.userId,
  });
}

// ========================================================================
// SUBMIT MINI PUZZLE ANSWER USE CASE IMPLEMENTATION
// Orchestrates the submission of a mini puzzle answer using the submission service.
// ========================================================================
class SubmitMiniPuzzleAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams> {
  // Dependency on the QuestSubmissionService
  final QuestSubmissionService
      submissionService; // Changed to public for direct access if needed, or keep private _submissionService

  SubmitMiniPuzzleAnswerUseCase({required this.submissionService});

  @override
  Future<Either<Failure, QuestSubmissionResult>> call(
      SubmitMiniPuzzleAnswerParams params) async {
    // Call the submission service to process the mini puzzle answer
    // Make sure QuestSubmissionService has a method like processMiniPuzzleSubmission or submitMiniPuzzleAnswer
    return await submissionService.processMiniPuzzleSubmission(
      // Assuming this method exists in QuestSubmissionService
      questId: params.questId,
      userId: params.userId,
      submittedAnswer: params.answer,
    );
  }
}
