// lib/presentation/providers/leaderboard_provider.dart
import 'package:flutter/material.dart';
import 'package:final_project/main.dart'; // Import getIt
import '../../domain/repositories/leaderboard_repositories.dart'; // Corrected import
import '../../domain/entities/leaderboard_entry.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepositories _leaderboardRepository; // Use the interface

  LeaderboardProvider(
      {required LeaderboardRepositories
          leaderboardRepository}) // Corrected constructor
      : _leaderboardRepository = leaderboardRepository;

  Stream<Either<Failure, List<LeaderboardEntry>>> get leaderboardStream =>
      _leaderboardRepository.getLeaderboardStream();

  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard() async {
    return await _leaderboardRepository.fetchLeaderboard();
  }
}
