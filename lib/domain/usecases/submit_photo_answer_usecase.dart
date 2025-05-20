import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import '../services/quest_submission_service.dart'; // Import the submission service
import 'submit_quest_answer_usecase.dart'; // Import the abstract use case and params

// ========================================================================
// SUBMIT PHOTO ANSWER USE CASE IMPLEMENTATION
// Orchestrates the submission of a photo challenge using the submission service.
// ========================================================================
class SubmitPhotoAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams> {
  // Dependency on the QuestSubmissionService
  final QuestSubmissionService _submissionService;

  SubmitPhotoAnswerUseCase({required QuestSubmissionService submissionService})
      : _submissionService = submissionService;

  @override
  Future<Either<Failure, QuestSubmissionResult>> call(
      SubmitPhotoAnswerParams params) async {
    // Call the submission service to process the photo challenge
    return await _submissionService.processPhotoChallengeSubmission(
      questId: params.questId,
      userId: params.userId,
      imagePath: params.imagePath,
    );
  }
}
