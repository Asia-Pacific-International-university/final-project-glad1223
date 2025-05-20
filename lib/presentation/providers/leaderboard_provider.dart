import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:dartz/dartz.dart';
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';
import 'package:rxdart/rxdart.dart'; // For .startWith on streams

// Define the LeaderboardState class to hold all leaderboard-related state
class LeaderboardState {
  final List<LeaderboardEntry> userLeaderboardList;
  final List<FacultyRanking> facultyRankingList;
  final bool isLoading;
  final String? errorMessage;

  LeaderboardState({
    this.userLeaderboardList = const [],
    this.facultyRankingList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? userLeaderboardList,
    List<FacultyRanking>? facultyRankingList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LeaderboardState(
      userLeaderboardList: userLeaderboardList ?? this.userLeaderboardList,
      facultyRankingList: facultyRankingList ?? this.facultyRankingList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Nullable, so pass null explicitly to clear
    );
  }
}

// Helper class to represent faculty ranking (remains the same)
class FacultyRanking {
  final String facultyName;
  final int totalScore;

  FacultyRanking({required this.facultyName, required this.totalScore});
}

// ========================================================================
// LEADERBOARD NOTIFIER (RIVERPOD STATE NOTIFIER)
// Manages leaderboard state and logic using Riverpod.
// ========================================================================
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardRepositories _leaderboardRepository;

  LeaderboardNotifier({required LeaderboardRepositories leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository,
        super(LeaderboardState()); // Initial state

  // Stream for real-time user leaderboard updates (directly exposed from repository)
  // This will be watched by the UI directly if needed for real-time updates.
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
}

// ========================================================================
// RIVERPOD PROVIDER DEFINITIONS
// ========================================================================

// The main LeaderboardProvider for Riverpod
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  // Ensure LeaderboardRepositories is also defined as a Riverpod provider
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
