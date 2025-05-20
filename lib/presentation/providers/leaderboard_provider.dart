import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_background_service/flutter_background_service.dart'; // Import background service
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';
import 'package:rxdart/rxdart.dart';

// Define the LeaderboardState class to hold all leaderboard-related state
class LeaderboardState {
  final List<LeaderboardEntry> userLeaderboardList;
  final List<FacultyRanking> facultyRankingList;
  final bool isLoading;
  final String? errorMessage;
  final bool isBackgroundUpdating; // New field to indicate background updates

  LeaderboardState({
    this.userLeaderboardList = const [],
    this.facultyRankingList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isBackgroundUpdating = false, // Initialize
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? userLeaderboardList,
    List<FacultyRanking>? facultyRankingList,
    bool? isLoading,
    String? errorMessage,
    bool? isBackgroundUpdating,
  }) {
    return LeaderboardState(
      userLeaderboardList: userLeaderboardList ?? this.userLeaderboardList,
      facultyRankingList: facultyRankingList ?? this.facultyRankingList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isBackgroundUpdating: isBackgroundUpdating ?? this.isBackgroundUpdating,
    );
  }
}

// Helper class to represent faculty ranking (remains the same)
class FacultyRanking {
  final String facultyName;
  final int totalScore;

  FacultyRanking({required this.facultyName, required this.totalScore});
}

// ---
// LEADERBOARD NOTIFIER (RIVERPOD STATE NOTIFIER)
// Manages leaderboard state and logic using Riverpod.
// ---
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardRepositories _leaderboardRepository;

  LeaderboardNotifier({required LeaderboardRepositories leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository,
        super(LeaderboardState()) {
    // Initialize the background service listener when the notifier is created
    _initBackgroundListeners();
  }

  // Stream for real-time user leaderboard updates (directly exposed from repository)
  Stream<Either<Failure, List<LeaderboardEntry>>> get userLeaderboardStream =>
      _leaderboardRepository.getLeaderboardStream();

  // Method to manually fetch the user leaderboard (snapshot)
  Future<void> fetchUserLeaderboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _leaderboardRepository.fetchLeaderboard();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          userLeaderboardList: [],
        );
      },
      (leaderboard) {
        state = state.copyWith(
          isLoading: false,
          userLeaderboardList: leaderboard,
          errorMessage: null,
        );
      },
    );
  }

  // Method to fetch and calculate faculty rankings (snapshot)
  Future<void> fetchFacultyRankings() async {
    state = state
        .copyWith(isLoading: true, errorMessage: null, facultyRankingList: []);

    final result = await _leaderboardRepository.fetchLeaderboard();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (leaderboard) {
        // Aggregate scores by faculty
        final facultyScores = <String, int>{};
        for (final entry in leaderboard) {
          if (entry.facultyName != null) {
            facultyScores[entry.facultyName!] =
                (facultyScores[entry.facultyName!] ?? 0) +
                    (entry.totalPoints); // Use totalPoints
          }
        }

        // Convert to a list of FacultyRanking and sort
        final rankings = facultyScores.entries
            .map((e) => FacultyRanking(
                  facultyName: e.key,
                  totalScore: e.value,
                ))
            .toList();
        rankings.sort((a, b) => b.totalScore.compareTo(a.totalScore));

        state = state.copyWith(
          isLoading: false,
          facultyRankingList: rankings,
          errorMessage: null,
        );
      },
    );
  }

  /// Initializes the listener for background service updates.
  void _initBackgroundListeners() {
    FlutterBackgroundService().on('leaderboard_update').listen((event) {
      if (event != null) {
        try {
          // Indicate that background update is in progress
          state = state.copyWith(isBackgroundUpdating: true);

          final updatedEntries = _parseLeaderboardEvent(event);
          state = state.copyWith(
            userLeaderboardList: updatedEntries,
            errorMessage:
                null, // Clear any previous errors on successful update
            isBackgroundUpdating: false, // Update complete
          );
          // Optional: Save to SQLite if needed here
        } catch (e) {
          state = state.copyWith(
            errorMessage: 'Failed to parse background leaderboard update: $e',
            isBackgroundUpdating: false, // Update complete with error
          );
        }
      }
    });
  }

  /// Parses incoming data from the background service into a list of LeaderboardEntry objects.
  List<LeaderboardEntry> _parseLeaderboardEvent(dynamic event) {
    // Assuming 'event' is a Map and contains a key 'entries' which is a List
    // of maps that can be converted to LeaderboardEntry.
    if (event is Map<String, dynamic> && event.containsKey('entries')) {
      final List<dynamic> entriesData = event['entries'];
      return entriesData
          .map((entry) =>
              LeaderboardEntry.fromJson(entry as Map<String, dynamic>))
          .toList();
    }
    throw const FormatException(
        'Invalid leaderboard event format from background service.');
  }
}

// ---
// RIVERPOD PROVIDER DEFINITIONS
// ---

// The main LeaderboardProvider for Riverpod
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final leaderboardRepository = ref.watch(leaderboardRepositoryProvider);
  return LeaderboardNotifier(leaderboardRepository: leaderboardRepository);
});

// Helper providers for specific parts of the state
final userLeaderboardListProvider = Provider<List<LeaderboardEntry>>((ref) {
  return ref
      .watch(leaderboardProvider.select((state) => state.userLeaderboardList));
});

final facultyRankingListProvider = Provider<List<FacultyRanking>>((ref) {
  return ref
      .watch(leaderboardProvider.select((state) => state.facultyRankingList));
});

final leaderboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(leaderboardProvider.select((state) => state.isLoading));
});

final leaderboardErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(leaderboardProvider.select((state) => state.errorMessage));
});

// New provider to indicate if background update is occurring
final leaderboardBackgroundUpdatingProvider = Provider<bool>((ref) {
  return ref
      .watch(leaderboardProvider.select((state) => state.isBackgroundUpdating));
});
