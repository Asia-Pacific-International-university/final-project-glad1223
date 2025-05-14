import 'package:dartz/dartz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/api_client.dart'; // Assuming you have an ApiClient
import '../models/leaderboard_model.dart'; // Assuming you have a LeaderboardModel (or directly use List<LeaderboardEntry>)

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepositoryImpl(this._apiClient);

  // Assuming your API provides a stream of leaderboard data (e.g., using WebSockets)
  @override
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream() {
    try {
      // Replace with your actual stream implementation
      return _apiClient.getLeaderboardStream('/leaderboard').map((event) {
        // Assuming the event contains a list of leaderboard data
        if (event is List) {
          final leaderboardEntries =
              event.map((json) => LeaderboardEntry.fromJson(json)).toList();
          return Right<Failure, List<LeaderboardEntry>>(leaderboardEntries);
        } else {
          return Left<Failure, List<LeaderboardEntry>>(ServerFailure());
        }
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard() async {
    try {
      final leaderboardData = await _apiClient
          .get('/leaderboard'); // Replace with your API endpoint
      if (leaderboardData is List) {
        final leaderboardEntries = (leaderboardData as List<dynamic>)
            .map((json) =>
                LeaderboardEntry.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(leaderboardEntries);
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
