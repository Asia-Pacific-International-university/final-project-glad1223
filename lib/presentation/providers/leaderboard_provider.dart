// lib/presentation/providers/leaderboard_provider.dart
import 'package:flutter/material.dart';
import 'package:final_project/domain/repositories/leaderboard_repositories.dart'; // Corrected import to the interface
import 'package:final_project/domain/entities/leaderboard_entry.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepositories _leaderboardRepository; // Use the interface

  LeaderboardProvider({required LeaderboardRepositories leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<LeaderboardEntry> _leaderboardList = [];
  List<LeaderboardEntry> get leaderboardList => _leaderboardList;

  // Expose the stream for real-time updates
  Stream<Either<Failure, List<LeaderboardEntry>>> get leaderboardStream =>
      _leaderboardRepository.getLeaderboardStream();

  // Method to manually fetch the leaderboard (can be used for initial load or refresh)
  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _leaderboardRepository.fetchLeaderboard();
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        _leaderboardList = [];
        notifyListeners();
      },
      (leaderboard) {
        _isLoading = false;
        _leaderboardList = leaderboard;
        notifyListeners();
      },
    );
  }
}
