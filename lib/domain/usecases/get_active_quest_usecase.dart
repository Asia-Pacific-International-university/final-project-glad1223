import 'package:final_project/core/usecases/usecase.dart'; // Assuming NoParamFutureUseCase is defined here
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';

class GetActiveQuestUseCase implements NoParamFutureUseCase<Quest?> {
  final QuestRepository _questRepository;

  GetActiveQuestUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Quest?> call() async {
    return await _questRepository.getActiveQuest();
  }
}
