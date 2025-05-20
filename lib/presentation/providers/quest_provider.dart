import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/usecases/get_active_quest_usecase.dart'; // Your use case
import 'package:final_project/core/error/failures.dart'; // Assuming Failure is here
import 'package:dartz/dartz.dart'; // For Either

// Import Repository and Data Source implementations
import 'package:final_project/domain/repositories/quest_repository.dart'; // Abstract repository
import 'package:final_project/data/repositories/quest_repository_impl.dart'; // Assuming implementation is here
import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart'; // Abstract data source
import 'package:final_project/data/datasources/remote/quest_remote_datasource_impl.dart'; // Assuming implementation is here
import 'package:http/http.dart' as http; // Assuming http client is used

// Import Submission Service and Use Cases
import 'package:final_project/domain/services/quest_submission_service.dart'; // The submission service
import 'package:final_project/domain/usecases/submit_trivia_answer_usecase.dart'; // Trivia use case
import 'package:final_project/domain/usecases/submit_location_answer_usecase.dart'; // Location use case
import 'package:final_project/domain/usecases/submit_photo_answer_usecase.dart'; // Photo use case
// Import other submission use cases as they are created
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import abstract use case and params


// --- Provider for http.Client (basic example) ---
// You might have this defined elsewhere; ensure it's available.
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// --- Provider for QuestRemoteDataSource ---
final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider); // Depends on httpClientProvider
  return QuestRemoteDataSourceImpl(client: client); // Assuming QuestRemoteDataSourceImpl takes http.Client
});

// --- Provider for QuestRepository ---
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final remoteDataSource = ref.watch(
      questRemoteDataSourceProvider); // Depends on questRemoteDataSourceProvider
  return QuestRepositoryImpl(remoteDataSource: remoteDataSource); // Assuming QuestRepositoryImpl takes QuestRemoteDataSource
});

// --- Provider for GetActiveQuestUseCase ---
final getActiveQuestUseCaseProvider = Provider<GetActiveQuestUseCase>((ref) {
  final repository =
      ref.watch(questRepositoryProvider); // Depends on questRepositoryProvider
  // Correctly pass named parameter based on the use case constructor
  return GetActiveQuestUseCase(questRepository: repository);
});

// --- Provider for QuestSubmissionService ---
final questSubmissionServiceProvider = Provider<QuestSubmissionService>((ref) {
  final questRepository = ref.watch(questRepositoryProvider); // Depends on QuestRepository
  // Assuming QuestSubmissionService takes QuestRepositoryImpl (or the interface)
  // Note: QuestSubmissionService expects QuestRepositoryImpl in its constructor based on its definition
  // You might need to cast or adjust the service's constructor to take the interface if preferred.
  return QuestSubmissionService(questRepository as QuestRepositoryImpl);
});


// --- Providers for Specific Submission Use Cases ---

final submitTriviaAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider); // Depends on SubmissionService
  return SubmitTriviaAnswerUseCase(submissionService: submissionService); // Assuming use case takes the service
});

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider); // Depends on SubmissionService
  return SubmitLocationAnswerUseCase(submissionService: submissionService); // Assuming use case takes the service
});

final submitPhotoAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider); // Depends on SubmissionService
  return SubmitPhotoAnswerUseCase(submissionService: submissionService); // Assuming use case takes the service
});

// TODO: Add providers for Poll and Mini-Puzzle submission use cases


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
    // getActiveQuestUseCase.call() returns Future<Either<Failure, Quest?>>
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
        // `quest` here is nullable `Quest?`
        state = AsyncValue.data(quest);
      },
    );
  }

  // Add methods here if the QuestNotifier needs to trigger submissions directly
  // For example, if a quest type has immediate submission without a separate widget button.
  // Generally, submission logic is handled within the specific quest widgets
  // using the submission use case providers.
}

final questProvider =
    StateNotifierProvider<QuestNotifier, AsyncValue<Quest?>>((ref) {
  final getActiveQuestUseCase = ref.watch(
      getActiveQuestUseCaseProvider); // Depends on getActiveQuestUseCaseProvider
  return QuestNotifier(getActiveQuestUseCase /*, ref */);
});
