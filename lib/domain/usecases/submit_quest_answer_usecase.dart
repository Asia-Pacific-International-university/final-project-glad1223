import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart'; // Import your custom failure class
import '../services/quest_submision_service.dart'; // Import the submission service

// ========================================================================
// ABSTRACT USE CASE FOR SUBMITTING QUEST ANSWERS
// Defines the contract for all quest submission use cases.
// ========================================================================

// Assuming this is the definition of ParamFutureUseCase
abstract class ParamFutureUseCase<Params, ReturnType> {
  Future<ReturnType> call(Params params);
}

// Abstract base class for all quest submission use cases
abstract class SubmitQuestAnswerUseCase<Params>
    implements
        ParamFutureUseCase<Params, Either<Failure, SubmissionResult>> {
  // The call method takes parameters and returns an Either with Failure or QuestSubmissionResult
  @override
  Future<Either<Failure, SubmissionResult>> call(Params params);
}

// --- Specific Use Case Parameters (Examples) ---
// These should be defined near their respective use case implementations or in a params file

// Parameters for submitting a Trivia answer
//class SubmitTriviaAnswerParams {
class SubmitTriviaAnswer {
  final String questId;
  final String answer;
  final String userId; // Include userId

  SubmitTriviaAnswerParams(
  SubmitTriviaAnswer(
      {required this.questId, required this.answer, required this.userId});
}

// Parameters for submitting a Poll vote
// class SubmitPollVoteParams {
class SubmitPollVote {
  final String questId;
  final String selectedOptionId;
  final String userId; // Include userId

  SubmitPollVoteParams(
      {required this.questId,
      required this.selectedOptionId,
      required this.userId});
}

// Parameters for submitting Location Check-in
// class SubmitLocationAnswerParams {
class SubmitLocationAnswer {
  final String questId;
  final double latitude;
  final double longitude;
  final String userId; // Include userId

  SubmitLocationAnswerParams({
    required this.questId,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}

// Parameters for submitting Photo Challenge
class SubmitPhotoAnswerParams {
  final String questId;
  final String imagePath;
  final String userId; // Include userId

  SubmitPhotoAnswerParams(
      {required this.questId, required this.imagePath, required this.userId});
}

// Parameters for submitting Mini-Puzzle
class SubmitMiniPuzzleAnswerParams {
  final String questId;
  final String puzzleAnswer;
  final String userId; // Include userId

  SubmitMiniPuzzleAnswerParams(
      {required this.questId,
      required this.puzzleAnswer,
      required this.userId});
}
