// lib/presentation/providers/quest_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/usecases/get_active_quest_usecase.dart'; // Your use case
import 'package:final_project/core/error/failures.dart'; // Assuming NotFoundFailure is here
import 'package:dartz/dartz.dart'; // For Either
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/data/repositories/quest_repository_impl.dart'; // Assuming implementation is here
import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart'; // Assuming definition is here
import 'package:final_project/data/datasources/remote/quest_remote_datasource_impl.dart'; // Assuming implementation is here
import 'package:http/http.dart' as http;

// --- Provider for http.Client (basic example) ---
// You might have this defined elsewhere; ensure it's available.
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// --- Provider for QuestRemoteDataSource ---
final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider); // Depends on httpClientProvider
  return QuestRemoteDataSourceImpl(client: client);
});

// --- Provider for QuestRepository ---
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final remoteDataSource = ref.watch(
      questRemoteDataSourceProvider); // Depends on questRemoteDataSourceProvider
  return QuestRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Provider for GetActiveQuestUseCase ---
// Ensure GetActiveQuestUseCase itself and its constructor are correct.
final getActiveQuestUseCaseProvider = Provider<GetActiveQuestUseCase>((ref) {
  final repository =
      ref.watch(questRepositoryProvider); // Depends on questRepositoryProvider
  // Correctly pass named parameter based on the use case constructor
  return GetActiveQuestUseCase(questRepository: repository);
});

// --- QuestNotifier and questProvider (THE MAIN PROVIDER FOR YOUR SCREEN) ---
class QuestNotifier extends StateNotifier<AsyncValue<Quest?>> {
  final GetActiveQuestUseCase _getActiveQuestUseCase;
  // Store the Ref to potentially read other providers if needed for actions
  // final Ref _ref; // Uncomment if you need to read other providers

  QuestNotifier(this._getActiveQuestUseCase /*, this._ref*/)
      : super(const AsyncValue.loading()) {
    fetchActiveQuest();
  }

  Future<void> fetchActiveQuest() async {
    state = const AsyncValue.loading();
    // getActiveQuestUseCase.call() now returns Future<Either<Failure, Quest>>
    // where Quest is non-nullable in the success case.
    final result = await _getActiveQuestUseCase.call();

    result.fold(
      (failure) {
        // If failure is NotFoundFailure, it means no active quest.
        // The UI handles AsyncValue.data(null) for "No active quest".
        // So, we map NotFoundFailure specifically to a success state with null data.
        // Other failures remain errors.
        if (failure is NotFoundFailure) {
          state = const AsyncValue.data(
              null); // Represent "no quest" as success with null
        } else {
          // In a real app, you might want more sophisticated error handling/logging
          print("Error fetching active quest in Notifier: ${failure.message}");
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
      (quest) {
        // `quest` here is non-nullable `Quest`
        state = AsyncValue.data(quest);
      },
    );
  }
}

final questProvider =
    StateNotifierProvider<QuestNotifier, AsyncValue<Quest?>>((ref) {
  final getActiveQuestUseCase = ref.watch(
      getActiveQuestUseCaseProvider); // Depends on getActiveQuestUseCaseProvider
  return QuestNotifier(getActiveQuestUseCase /*, ref */);
});
