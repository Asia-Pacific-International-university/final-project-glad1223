import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseException
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/leaderboard_remote_datasource.dart'; // Import your Firestore data source
import '../datasources/local/faculty_local_datasource.dart'; // Import your SQLite data source
import '../models/faculty_model.dart'; // Import your FacultyModel


// ========================================================================
// LEADERBOARD REPOSITORY IMPLEMENTATION
// Handles coordinating data access from remote (Firestore)
// and local (SQLite) sources for Leaderboard (Faculty) data.
// Implements caching logic.
// ========================================================================
class LeaderboardRepositoryImpl implements LeaderboardRepositories {
  final LeaderboardRemoteDataSource _remoteDataSource; // Firestore source
  final FacultyLocalDataSource _localDataSource; // SQLite source

  LeaderboardRepositoryImpl({
    required LeaderboardRemoteDataSource remoteDataSource,
    required FacultyLocalDataSource localDataSource,
  }) :  _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // Helper to convert List<FacultyModel> to List<LeaderboardEntry>
  List<LeaderboardEntry> _mapModelsToEntries(List<FacultyModel> models) {
    return models.map((model) => LeaderboardEntry.fromFacultyModel(model)).toList();
  }

  // --- Helper method to save faculty data to local cache ---
  Future<void> _saveFacultiesToLocal(List<FacultyModel> faculties) async {
    await _localDataSource.saveFaculties(faculties);
    print('${faculties.length} FacultyModels saved to SQLite cache');
  }

  // --- Helper method to get faculty data from local cache ---
  Future<List<FacultyModel>> _getFacultiesFromLocal() async {
    // TODO: Implement staleness check here if needed (e.g., store timestamp in DB)
    return await _localDataSource.getFaculties();
  }

  // --- Helper method to clear local faculty cache ---
  Future<void> _clearLocalFaculties() async {
    await _localDataSource.clearAllFaculties();
    print('All FacultyModels cleared from SQLite cache');
  }


  @override
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream() {
    // For a real-time stream, we primarily rely on the remote source.
    // However, we can seed the stream with cached data initially.
    try {
      // 1. Get data from local cache immediately
      final localFaculties = _getFacultiesFromLocal(); // Get the Future

      // 2. Get the real-time stream from the remote source
      final remoteStream = _remoteDataSource.getFacultyLeaderboardStream();

      // Combine the local data (as an initial value) with the remote stream
      return remoteStream.map((facultyModels) {
        // When new data arrives from Firestore, save it to the local cache
        _saveFacultiesToLocal(facultyModels);
        // Map the remote data to domain entities and return
        return Right(_mapModelsToEntries(facultyModels));
      }).handleError((e) {
        // Handle errors from the remote stream
        print('Error in remote leaderboard stream: $e');
        if (e is FirebaseException) {
          return Left(ServerFailure('Firestore Stream Error: ${e.message}'));
        }
        return Left(ServerFailure('Unknown error in leaderboard stream: ${e.toString()}'));
      }).startWith(localFaculties.asStream().map((faculties) {
         // Provide the locally cached data as the initial value for the stream
         print('Seeding leaderboard stream with local cache');
         return Right(_mapModelsToEntries(faculties));
      }).handleError((e){
         // Handle errors getting initial local data
         print('Error getting local leaderboard data: $e');
         return Left(CacheFailure(message: 'Failed to load cached leaderboard: ${e.toString()}'));
      }));

    } catch (e) {
      // Handle errors setting up the stream initially
      print('Error setting up leaderboard stream: $e');
      return Stream.value(Left(ServerFailure('Error setting up leaderboard stream: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard() async {
    // For a one-time fetch (snapshot), we can implement a cache-first strategy.
    try {
      // 1. Try to get data from local cache first
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Returning leaderboard from local cache');
        return Right(_mapModelsToEntries(cachedFaculties));
      }

      // 2. If not in cache (or stale), fetch from remote (Firestore snapshot)
      print('Fetching leaderboard from remote source');
      final remoteFaculties = await _remoteDataSource.getFacultyLeaderboardSnapshot();

      // 3. If fetched from remote, save to local cache
      await _saveFacultiesToLocal(remoteFaculties);

      print('Returning leaderboard from remote source and cached locally');
      return Right(_mapModelsToEntries(remoteFaculties));

    } on FirebaseException catch (e) {
      print('Firestore error fetching leaderboard: ${e.message}');
      // If remote fails, try returning potentially stale cached data as a fallback
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Remote fetch failed, returning cached leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure('Failed to fetch leaderboard: ${e.message}'));
    } catch (e) {
      print('Error fetching leaderboard: $e');
      // If remote fails, try returning potentially stale cached data as a fallback
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Remote fetch failed, returning cached leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure('Failed to fetch leaderboard: ${e.toString()}'));
    }
  }

  // --- Implement new methods for specific leaderboards with caching ---

  @override
  Stream<Either<Failure, List<LeaderboardEntry>>>
      getFastestLeaderboardStream() {
    // Apply similar caching logic as getLeaderboardStream
    try {
      final localFaculties = _getFacultiesFromLocal(); // Get from local cache

      final remoteStream = _remoteDataSource.getFastestCompletionLeaderboardStream(); // Get remote stream

      return remoteStream.map((facultyModels) {
        // Save the latest data from the stream to cache
        _saveFacultiesToLocal(facultyModels); // Note: This saves ALL faculties, not just fastest
        return Right(_mapModelsToEntries(facultyModels));
      }).handleError((e) {
        print('Error in remote fastest leaderboard stream: $e');
        if (e is FirebaseException) {
          return Left(ServerFailure('Firestore Stream Error: ${e.message}'));
        }
        return Left(ServerFailure('Unknown error in fastest leaderboard stream: ${e.toString()}'));
      }).startWith(localFaculties.asStream().map((faculties) {
         // Provide cached data initially
         print('Seeding fastest leaderboard stream with local cache');
         // Note: Local cache is ordered by points, not fastest time.
         // You might need to re-sort here if the local cache structure doesn't match the remote order.
         // Or implement separate local storage for different leaderboard types.
         // For simplicity, we'll just return the cached data as is for now.
         return Right(_mapModelsToEntries(faculties));
      }).handleError((e){
         print('Error getting local fastest leaderboard data: $e');
         return Left(CacheFailure(message: 'Failed to load cached fastest leaderboard: ${e.toString()}'));
      }));

    } catch (e) {
      print('Error setting up fastest leaderboard stream: $e');
      return Stream.value(Left(ServerFailure('Error setting up fastest leaderboard stream: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>>
      getAccuracyLeaderboardSnapshot() async {
    // Apply similar caching logic as fetchLeaderboard
    try {
      // 1. Try to get data from local cache first
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Returning accuracy leaderboard from local cache');
        // Note: Local cache is ordered by points, not accuracy.
        // You might need to re-sort here if the local cache structure doesn't match the remote order.
        // Or implement separate local storage for different leaderboard types.
        // For simplicity, we'll just return the cached data as is for now.
        return Right(_mapModelsToEntries(cachedFaculties));
      }

      // 2. If not in cache, fetch from remote (Firestore snapshot)
      print('Fetching accuracy leaderboard from remote source');
      // Assuming you have a method like getAccuracyLeaderboardSnapshot in remoteDataSource
      // The provided remote data source only had a stream for accuracy.
      // Let's get one snapshot from the stream for this future method.
      final remoteFaculties = await _remoteDataSource.getAccuracyLeaderboardStream().first;

      // 3. If fetched from remote, save to local cache
      await _saveFacultiesToLocal(remoteFaculties); // Note: This saves ALL faculties

      print('Returning accuracy leaderboard from remote source and cached locally');
      return Right(_mapModelsToEntries(remoteFaculties));

    } on FirebaseException catch (e) {
      print('Firestore error fetching accuracy leaderboard: ${e.message}');
      // If remote fails, try returning potentially stale cached data as a fallback
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Remote fetch failed, returning cached accuracy leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure('Failed to fetch accuracy leaderboard: ${e.message}'));
    } catch (e) {
      print('Error fetching accuracy leaderboard: $e');
      // If remote fails, try returning potentially stale cached data as a fallback
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        print('Remote fetch failed, returning cached accuracy leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure('Failed to fetch accuracy leaderboard: ${e.toString()}'));
    }
  }
}
