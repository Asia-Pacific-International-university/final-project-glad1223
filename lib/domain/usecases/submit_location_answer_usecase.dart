import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import '../services/quest_submission_service.dart'; // Import the submission service
import 'submit_quest_answer_usecase.dart'; // Import the abstract use case and params

// ========================================================================
// SUBMIT LOCATION ANSWER USE CASE IMPLEMENTATION
// Orchestrates the submission of a location check-in using the submission service.
// ========================================================================
class SubmitLocationAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitLocationAnswerParams> {
  // Dependency on the QuestSubmissionService
  final QuestSubmissionService _submissionService;

  SubmitLocationAnswerUseCase({required QuestSubmissionService submissionService})
      : _submissionService = submissionService;

  @override
  Future<Either<Failure, QuestSubmissionResult>> call(SubmitLocationAnswerParams params) async {
    // Call the submission service to process the location check-in
    return await _submissionService.processLocationCheckInSubmission(
      questId: params.questId,
      userId: params.userId,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
