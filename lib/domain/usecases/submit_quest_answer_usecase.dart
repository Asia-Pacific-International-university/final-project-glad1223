import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/core/error/failures.dart'; // Import your custom failure class
import 'package:dartz/dartz.dart'; // Import Either
import 'package:flutter/foundation.dart';

abstract class SubmitQuestAnswerUseCase<Params, ReturnType>
    implements ParamFutureUseCase<Params, ReturnType> {}

class SubmitTriviaAnswerParams {
  final String questId;
  final String answer;

  SubmitTriviaAnswerParams({required this.questId, required this.answer});
}

class SubmitTriviaAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams, String> {
  // Changed return type to String
  final QuestRepository _questRepository;

  SubmitTriviaAnswerUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, String>> call(SubmitTriviaAnswerParams params) async {
    // Changed return type to String
    try {
      final result = await _questRepository.submitTriviaAnswer(
          params.questId, params.answer);
      // Check the result explicitly.
      return result.fold(
        (failure) => Left(failure),
        (success) =>
            Right(success), // Return the success value (which is a String)
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error in SubmitTriviaAnswerUseCase: $e");
      }
      // Construct a specific Failure, or wrap the exception.
      return Left(UnexpectedFailure(
          message:
              'An unexpected error occurred: $e')); // Use the defined UnexpectedFailure
    }
  }
}

// Similar Params and UseCase implementations for other quest types (Poll, Location, Photo)
