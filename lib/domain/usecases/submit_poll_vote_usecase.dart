import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import 'package:final_project/domain/services/quest_submision_service.dart'; // Import the submission service
import 'submit_quest_answer_usecase.dart'; // Import the abstract use case and QuestSubmissionResult

// Define the parameter class for Poll Vote submission
class SubmitPollVoteParams {
  final String questId;
  final String userId;
  final String pollId;
  final String selectedOption; // The ID or value of the selected poll option

  SubmitPollVoteParams({
    required this.questId,
    required this.userId,
    required this.pollId,
    required this.selectedOption,
  });
}

// ========================================================================
// SUBMIT POLL VOTE USE CASE IMPLEMENTATION
// Orchestrates the submission of a poll vote using the submission service.
// ========================================================================
class SubmitPollVoteUseCase
    implements SubmitQuestAnswerUseCase<SubmitPollVoteParams> {
  // Dependency on the QuestSubmissionService
  final QuestSubmissionService _submissionService;

  SubmitPollVoteUseCase({required QuestSubmissionService submissionService})
      : _submissionService = submissionService;

  @override
  Future<Either<Failure, QuestSubmissionResult>> call(
      SubmitPollVoteParams params) async {
    // Call the submission service to process the poll vote
    return await _submissionService.processPollVoteSubmission(
      questId: params.questId,
      userId: params.userId,
      pollId: params.pollId,
      selectedOption: params.selectedOption,
    );
  }
}

// import 'package:dartz/dartz.dart';
// import '../../core/error/failures.dart';
// import '../../core/usecases/usecase.dart';
// import '../services/quest_submision_service.dart'; // Import SubmissionResult

// class SubmitPollVoteUseCase
//     implements UseCase<SubmissionResult, SubmitPollVoteParams> {
//   final QuestSubmissionService submissionService;

//   SubmitPollVoteUseCase({required this.submissionService});

//   @override
//   Future<Either<Failure, SubmissionResult>> call(
//       SubmitPollVoteParams params) async {
//     return await submissionService.submitPollVote(
//       questId: params.questId,
//       optionId: params.optionId,
//       userId: params.userId,
//     );
//   }
// }

// class SubmitPollVoteParams {
//   final String questId;
//   final String optionId;
//   final String userId;

//   SubmitPollVoteParams({
//     required this.questId,
//     required this.optionId,
//     required this.userId,
//   });
// }
