import 'package:final_project/core/usecases/testing';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';

class GetActiveQuestUseCase implements NoParamFutureUseCase<Quest?> {
  final QuestRepository _questRepository;

  GetActiveQuestUseCase({required this.questRepository});

  @override
  Future<Quest?> execute() async {
    return await _questRepository.getActiveQuest();
  }
}
