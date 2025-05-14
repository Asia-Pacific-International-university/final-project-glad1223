// lib/presentation/providers/quest_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/usecases/get_active_quest_usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/data/repositories/quest_repository_impl.dart';
import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/data/datasources/remote/quest_remote_datasource_impl.dart';
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import the UseCase
//import 'package:final_project/domain/repositories/user_repositories.dart'; // Import the UserRepository (if needed by the UseCase)
import 'package:http/http.dart' as http;

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

final submitQuestAnswerUseCaseProvider = Provider<SubmitQuestAnswerUseCase>(
  (ref) => SubmitQuestAnswerUseCase(
    questRepository:
        ref.read(questRepositoryProvider), // Assuming you have this provider
    // userRepository: ref.read(userRepositoryProvider),      // Assuming you have this provider if needed
  ),
);

// Assuming you have a UserRepository and its provider defined elsewhere
// final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl(...));
