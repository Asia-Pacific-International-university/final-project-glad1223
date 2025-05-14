import 'package:final_project/core/usecases/testing';

abstract class SubmitQuestAnswerUseCase<Params>
    implements FutureUseCase<void, Params> {}

class SubmitTriviaAnswerParams {
  final String questId;
  final String answer;

  SubmitTriviaAnswerParams({required this.questId, required this.answer});
}

class SubmitTriviaAnswerUseCase
    implements SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams> {
  final QuestRepository _questRepository;

  SubmitTriviaAnswerUseCase({required this.questRepository});

  @override
  Future<void> execute(SubmitTriviaAnswerParams params) async {
    return await _questRepository.submitTriviaAnswer(
        params.questId, params.answer);
  }
}

// Similar Params and UseCase implementations for other quest types (Poll, Location, Photo)
