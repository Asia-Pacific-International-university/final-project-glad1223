import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Alias for clarity
import 'package:final_project/domain/usecases/get_active_quest_usecase.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_background_service/flutter_background_service.dart'; // Import background service

// Import Repository and Data Source implementations
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/data/repositories/quest_repository_impl.dart';
import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/data/datasources/remote/quest_remote_datasource_impl.dart';
import 'package:http/http.dart' as http;

// Import Submission Service and Use Cases
import 'package:final_project/domain/services/quest_submission_service.dart';
import 'package:final_project/domain/usecases/submit_trivia_answer_usecase.dart';
import 'package:final_project/domain/usecases/submit_location_answer_usecase.dart';
import 'package:final_project/domain/usecases/submit_photo_answer_usecase.dart';
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart';

// --- Provider for http.Client (basic example) ---
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// --- Provider for QuestRemoteDataSource ---
final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return QuestRemoteDataSourceImpl(client: client);
});

// --- Provider for QuestRepository ---
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final remoteDataSource = ref.watch(questRemoteDataSourceProvider);
  return QuestRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Provider for GetActiveQuestUseCase ---
final getActiveQuestUseCaseProvider = Provider<GetActiveQuestUseCase>((ref) {
  final repository = ref.watch(questRepositoryProvider);
  return GetActiveQuestUseCase(questRepository: repository);
});

// --- Provider for QuestSubmissionService ---
final questSubmissionServiceProvider = Provider<QuestSubmissionService>((ref) {
  final questRepository = ref.watch(questRepositoryProvider);
  return QuestSubmissionService(questRepository as QuestRepositoryImpl);
});

// --- Providers for Specific Submission Use Cases ---

final submitTriviaAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitTriviaAnswerUseCase(submissionService: submissionService);
});

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitLocationAnswerUseCase(submissionService: submissionService);
});

final submitPhotoAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitPhotoAnswerUseCase(submissionService: submissionService);
});

// --- QuestNotifier and questProvider (THE MAIN PROVIDER FOR YOUR SCREEN) ---
class QuestNotifier extends StateNotifier<AsyncValue<q.Quest?>> {
  final GetActiveQuestUseCase _getActiveQuestUseCase;

  QuestNotifier(this._getActiveQuestUseCase)
      : super(const AsyncValue.loading()) {
    fetchActiveQuest();
    // Initialize the background service listener when the notifier is created
    _initBackgroundListeners();
  }

  Future<void> fetchActiveQuest() async {
    state = const AsyncValue.loading();
    final result = await _getActiveQuestUseCase.call();

    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          state = const AsyncValue.data(null);
        } else {
          print("Error fetching active quest in Notifier: ${failure.message}");
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
      (quest) {
        state = AsyncValue.data(quest);
      },
    );
  }

  /// Initializes the listener for background service updates.
  void _initBackgroundListeners() {
    FlutterBackgroundService().on('quest_update').listen((event) {
      if (event != null) {
        try {
          final updatedQuest = _parseQuestEvent(event);
          state = AsyncValue.data(updatedQuest);
          // Optional: Store locally if needed
        } catch (e) {
          // Handle parsing errors or unexpected event formats
          print("Error parsing quest update from background service: $e");
          state = AsyncValue.error(
            'Failed to parse background quest update: $e',
            StackTrace.current,
          );
        }
      }
    });
  }

  /// Parses incoming data from the background service into a Quest entity.
  /// Assumes the 'event' directly represents the Quest JSON data.
  q.Quest _parseQuestEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      return q.Quest.fromJson(event);
    }
    throw const FormatException(
        'Invalid quest event format from background service. Expected a Map.');
  }
}

final questProvider =
    StateNotifierProvider<QuestNotifier, AsyncValue<q.Quest?>>((ref) {
  final getActiveQuestUseCase = ref.watch(getActiveQuestUseCaseProvider);
  return QuestNotifier(getActiveQuestUseCase);
});
