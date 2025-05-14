import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_entry.dart'; // Assuming an entity for leaderboard entries
import '../../domain/repositories/leaderboard_repositories.dart'; // Assuming a LeaderboardRepository
import '../../core/error/failures.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _leaderboardRepository;

  LeaderboardProvider(this._leaderboardRepository) {
    _listenToLeaderboard();
  }

  List<LeaderboardEntry> _leaderboardList = [];
  List<LeaderboardEntry> get leaderboardList => _leaderboardList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Stream<Either<Failure, List<LeaderboardEntry>>>? _leaderboardStream;

  void _listenToLeaderboard() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _leaderboardStream = _leaderboardRepository.getLeaderboardStream();
    _leaderboardStream?.listen((result) {
      result.fold(
        (failure) {
          _isLoading = false;
          _errorMessage = _mapFailureToMessage(failure);
          _leaderboardList = [];
          notifyListeners();
        },
        (leaderboardEntries) {
          _isLoading = false;
          _leaderboardList = leaderboardEntries;
          notifyListeners();
        },
      );
    });
  }

  // Method to manually refresh the leaderboard (if needed)
  Future<void> refreshLeaderboard() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _leaderboardRepository
        .fetchLeaderboard(); // Assuming a fetch method
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (leaderboardEntries) {
        _isLoading = false;
        _leaderboardList = leaderboardEntries;
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Failed to fetch leaderboard data from the server.';
      case CacheFailure:
        return 'Failed to load leaderboard data from cache.';
      default:
        return 'An unexpected error occurred while loading leaderboard data.';
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing stream subscriptions if necessary
    super.dispose();
  }
}
