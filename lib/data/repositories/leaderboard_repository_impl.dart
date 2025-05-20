// data/repositories/leaderboard_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/leaderboard_remote_datasource.dart'; // Import your Firestore data source
import '../models/faculty_model.dart'; // Import your FacultyModel

class LeaderboardRepositoryImpl implements LeaderboardRepositories {
  final LeaderboardRemoteDataSource _remoteDataSource; // Changed dependency

  LeaderboardRepositoryImpl(
      this._remoteDataSource); // Constructor now takes remoteDataSource

  @override
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream() {
    try {
      final stream = _remoteDataSource
          .getFacultyLeaderboardStream(); // Use Firestore stream
      return stream.map((facultyModels) {
        final leaderboardEntries = facultyModels
            .map((model) => LeaderboardEntry.fromFacultyModel(
                model)) // Map FacultyModel to LeaderboardEntry
            .toList();
        return Right(leaderboardEntries);
      }).handleError((e) {
        // Handle errors from the stream itself
        if (e is FirebaseException) {
          return Left(ServerFailure('Firestore Error: ${e.message}'));
        }
        return Left(ServerFailure('Unknown error getting stream: $e'));
      });
    } catch (e) {
      return Stream.value(
          Left(ServerFailure('Error setting up leaderboard stream: $e')));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard() async {
    try {
      final facultyModels = await _remoteDataSource
          .getFacultyLeaderboardSnapshot(); // Use Firestore snapshot
      final leaderboardEntries = facultyModels
          .map((model) => LeaderboardEntry.fromFacultyModel(model))
          .toList();
      return Right(leaderboardEntries);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore Error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error fetching leaderboard: $e'));
    }
  }

  // --- Implement new methods for specific leaderboards ---
  @override
  Stream<Either<Failure, List<LeaderboardEntry>>>
      getFastestLeaderboardStream() {
    try {
      final stream = _remoteDataSource.getFastestCompletionLeaderboardStream();
      return stream.map((facultyModels) {
        final leaderboardEntries = facultyModels
            .map((model) => LeaderboardEntry.fromFacultyModel(model))
            .toList();
        return Right(leaderboardEntries);
      }).handleError((e) {
        if (e is FirebaseException) {
          return Left(ServerFailure('Firestore Error: ${e.message}'));
        }
        return Left(ServerFailure('Unknown error getting fastest stream: $e'));
      });
    } catch (e) {
      return Stream.value(Left(
          ServerFailure('Error setting up fastest leaderboard stream: $e')));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>>
      getAccuracyLeaderboardSnapshot() async {
    try {
      // Assuming you have a method like getAccuracyLeaderboardSnapshot in remoteDataSource
      final facultyModels = await _remoteDataSource
          .getAccuracyLeaderboardStream()
          .first; // Get one snapshot from stream
      final leaderboardEntries = facultyModels
          .map((model) => LeaderboardEntry.fromFacultyModel(model))
          .toList();
      return Right(leaderboardEntries);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firestore Error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error fetching accuracy leaderboard: $e'));
    }
  }
}
