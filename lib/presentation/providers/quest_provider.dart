import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/usecases/get_active_quest_usecase.dart';

class QuestNotifier extends StateNotifier<AsyncValue<Quest?>> {
  final GetActiveQuestUseCase _getActiveQuestUseCase;

  QuestNotifier({required GetActiveQuestUseCase getActiveQuestUseCase})
      : _getActiveQuestUseCase = getActiveQuestUseCase,
        super(const AsyncValue.loading()) {
    loadActiveQuest();
  }

  Future<void> loadActiveQuest() async {
    state = const AsyncValue.loading();
    final result = await _getActiveQuestUseCase.execute();
    state = AsyncValue.data(result);
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, AsyncValue<Quest?>>(
  (ref) => QuestNotifier(
    getActiveQuestUseCase: ref.read(getActiveQuestUseCaseProvider),
  ),
);

final getActiveQuestUseCaseProvider = Provider<GetActiveQuestUseCase>(
  (ref) => GetActiveQuestUseCase(
    questRepository: ref.read(questRepositoryProvider),
  ),
);

final questRepositoryProvider = Provider<QuestRepository>(
  (ref) => QuestRepositoryImpl(
    remoteDataSource: ref.read(questRemoteDataSourceProvider),
  ),
);

final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>(
  (ref) => QuestRemoteDataSourceImpl(client: http.Client()),
);

// Providers for SubmitAnswer Use Cases
final submitTriviaAnswerUseCaseProvider = Provider<SubmitTriviaAnswerUseCase>(
  (ref) => SubmitTriviaAnswerUseCase(
      questRepository: ref.read(questRepositoryProvider)),
);
// ... other submit use case providers
