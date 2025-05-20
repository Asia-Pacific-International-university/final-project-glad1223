// lib/presentation/providers/leaderboard_provider.dart
import 'package:flutter/material.dart';
import 'package:final_project/domain/repositories/leaderboard_repositories.dart';
import 'package:final_project/domain/entities/leaderboard_entry.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepositories _leaderboardRepository;

  LeaderboardProvider({required LeaderboardRepositories leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<LeaderboardEntry> _userLeaderboardList = [];
  List<LeaderboardEntry> get userLeaderboardList => _userLeaderboardList;

  List<FacultyRanking> _facultyRankingList = [];
  List<FacultyRanking> get facultyRankingList => _facultyRankingList;

  // Stream for real-time user leaderboard updates
  Stream<Either<Failure, List<LeaderboardEntry>>> get userLeaderboardStream =>
      _leaderboardRepository.getLeaderboardStream();

  // Method to manually fetch the user leaderboard
  Future<void> fetchUserLeaderboard() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _leaderboardRepository.fetchLeaderboard();
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        _userLeaderboardList = [];
        notifyListeners();
      },
      (leaderboard) {
        _isLoading = false;
        _userLeaderboardList = leaderboard;
        notifyListeners();
      },
    );
  }

  // Method to fetch and calculate faculty rankings
  Future<void> fetchFacultyRankings() async {
    _isLoading = true;
    _errorMessage = '';
    _facultyRankingList = []; // Clear previous rankings
    notifyListeners();

    final result = await _leaderboardRepository.fetchLeaderboard();
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (leaderboard) {
        // Aggregate scores by faculty
        final facultyScores = <String, int>{};
        for (final entry in leaderboard) {
          if (entry.facultyName != null) {
            facultyScores[entry.facultyName!] =
                (facultyScores[entry.facultyName!] ?? 0) + (entry.score ?? 0);
          }
        }

        // Convert to a list of FacultyRanking and sort
        _facultyRankingList = facultyScores.entries
            .map((e) => FacultyRanking(
                  facultyName: e.key,
                  totalScore: e.value,
                ))
            .toList();
        _facultyRankingList
            .sort((a, b) => b.totalScore.compareTo(a.totalScore));

        _isLoading = false;
        notifyListeners();
      },
    );
  }
}

// Helper class to represent faculty ranking
class FacultyRanking {
  final String facultyName;
  final int totalScore;

  FacultyRanking({required this.facultyName, required this.totalScore});
}
