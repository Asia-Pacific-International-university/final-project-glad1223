import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/core/error/failures.dart'; // Likely needed for Either
import 'package:dartz/dartz.dart'; // Import Either

abstract class SubmitQuestAnswerUseCase<Params>
    implements
        ParamFutureUseCase<Params, void> {} // Changed to ParamFutureUseCase

class SubmitTriviaAnswerParams {
  final String questId;
  final String answer;

  SubmitTriviaAnswerParams({required this.questId, required this.answer});
}

class SubmitTriviaAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams> {
  final QuestRepository _questRepository;

  SubmitTriviaAnswerUseCase(
      {required QuestRepository
          questRepository}) // Corrected type and parameter name
      : _questRepository = questRepository; // Initializer list

  @override
  Future<Either<Failure, void>> call(SubmitTriviaAnswerParams params) async {
    // Changed execute to call and return type
    final result = await _questRepository.submitTriviaAnswer(
        params.questId, params.answer);
    return result; // Assuming submitTriviaAnswer returns Either<Failure, void>
  }
}

// Similar Params and UseCase implementations for other quest types (Poll, Location, Photo)
