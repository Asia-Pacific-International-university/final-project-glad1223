import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/leaderboard_entry.dart';
// FIX: Correct the import to point to the file defining the singular interface
import '../../domain/repositories/leaderboard_repositories.dart'; // Changed from leaderboard_repositories.dart
import '../../core/error/failures.dart';
import '../datasources/remote/leaderboard_remote_datasource.dart';
import '../datasources/local/faculty_local_datasource.dart';
import '../models/faculty_model.dart';
import 'package:rxdart/rxdart';
// FIX: Import the new extension
import 'package:final_project/core/extension/stream_either_extension.dart'; // Corrected path if needed, usually 'extensions' not 'extension'

// ========================================================================
// LEADERBOARD REPOSITORY IMPLEMENTATION
// ========================================================================
// FIX: Change 'LeaderboardRepositories' to 'LeaderboardRepository' (singular)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _remoteDataSource;
  final FacultyLocalDataSource _localDataSource;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  LeaderboardRepositoryImpl({
    required LeaderboardRemoteDataSource remoteDataSource,
    required FacultyLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  List<LeaderboardEntry> _mapModelsToEntries(List<FacultyModel> models) {
    return models
        .map((model) => LeaderboardEntry.fromFacultyModel(model))
        .toList();
  }

  Future<void> _saveFacultiesToLocal(List<FacultyModel> faculties) async {
    await _localDataSource.saveFaculties(faculties);
    _logger.i('${faculties.length} FacultyModels saved to SQLite cache');
  }

  Future<List<FacultyModel>> _getFacultiesFromLocal() async {
    return await _localDataSource.getFaculties();
  }

  Future<void> _clearLocalFaculties() async {
    await _localDataSource.clearAllFaculties();
    _logger.i('All FacultyModels cleared from SQLite cache');
  }

  // Helper function for mapping errors to Failures
  Failure _mapStreamErrorToFailure(
      dynamic error, StackTrace stackTrace, String contextMessage) {
    _logger.e('$contextMessage: $error', error, stackTrace);
    if (error is FirebaseException) {
      return ServerFailure('Firestore Stream Error: ${error.message}');
    }
    return ServerFailure('Unknown error in stream: ${error.toString()}');
  }

  @override
  Stream<Either<Failure, List<LeaderboardEntry>>> getLeaderboardStream() {
    final localFuture = _getFacultiesFromLocal();

    final localStreamOfEntries = localFuture.asStream().map((faculties) {
      _logger.d('Seeding leaderboard stream with local cache');
      return _mapModelsToEntries(faculties);
    });

    final localStreamWithEither = localStreamOfEntries.toEitherStream(
        (error, stackTrace) => _mapStreamErrorToFailure(
            error, stackTrace, 'Error getting local leaderboard data'));

    final remoteSourceStream = _remoteDataSource.getFacultyLeaderboardStream();

    final remoteStreamOfEntries = remoteSourceStream.map((facultyModels) {
      _saveFacultiesToLocal(facultyModels);
      return _mapModelsToEntries(facultyModels);
    });

    final remoteStreamWithEither = remoteStreamOfEntries.toEitherStream(
        (error, stackTrace) => _mapStreamErrorToFailure(
            error, stackTrace, 'Error in remote leaderboard stream'));

    return remoteStreamWithEither.startWithStream(localStreamWithEither);
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> fetchLeaderboard() async {
    try {
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.i('Returning leaderboard from local cache');
        return Right(_mapModelsToEntries(cachedFaculties));
      }

      _logger.i('Fetching leaderboard from remote source');
      final remoteFaculties =
          await _remoteDataSource.getFacultyLeaderboardSnapshot();

      await _saveFacultiesToLocal(remoteFaculties);

      _logger.i('Returning leaderboard from remote source and cached locally');
      return Right(_mapModelsToEntries(remoteFaculties));
    } on FirebaseException catch (e, stackTrace) {
      _logger.e(
          'Firestore error fetching leaderboard: ${e.message}', e, stackTrace);
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.w(
            'Remote fetch failed, returning cached leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure('Failed to fetch leaderboard: ${e.message}'));
    } catch (e, stackTrace) {
      _logger.e('Error fetching leaderboard: $e', e, stackTrace);
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.w(
            'Remote fetch failed, returning cached leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(
          ServerFailure('Failed to fetch leaderboard: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<LeaderboardEntry>>>
      getFastestLeaderboardStream() {
    final localFuture = _getFacultiesFromLocal();

    final localStreamOfEntries = localFuture.asStream().map((faculties) {
      _logger.d('Seeding fastest leaderboard stream with local cache');
      return _mapModelsToEntries(faculties);
    });

    final localStreamWithEither = localStreamOfEntries.toEitherStream(
        (error, stackTrace) => _mapStreamErrorToFailure(
            error, stackTrace, 'Error getting local fastest leaderboard data'));

    final remoteStream =
        _remoteDataSource.getFastestCompletionLeaderboardStream();

    final remoteStreamOfEntries = remoteStream.map((facultyModels) {
      _saveFacultiesToLocal(facultyModels);
      return _mapModelsToEntries(facultyModels);
    });

    final remoteStreamWithEither = remoteStreamOfEntries.toEitherStream(
        (error, stackTrace) => _mapStreamErrorToFailure(
            error, stackTrace, 'Error in remote fastest leaderboard stream'));

    return remoteStreamWithEither.startWithStream(localStreamWithEither);
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>>
      getAccuracyLeaderboardSnapshot() async {
    try {
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.i('Returning accuracy leaderboard from local cache');
        return Right(_mapModelsToEntries(cachedFaculties));
      }

      _logger.i('Fetching accuracy leaderboard from remote source');
      final remoteFaculties =
          await _remoteDataSource.getAccuracyLeaderboardStream().first;

      await _saveFacultiesToLocal(remoteFaculties);

      _logger.i(
          'Returning accuracy leaderboard from remote source and cached locally');
      return Right(_mapModelsToEntries(remoteFaculties));
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('Firestore error fetching accuracy leaderboard: ${e.message}',
          e, stackTrace);
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.w(
            'Remote fetch failed, returning cached accuracy leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(
          ServerFailure('Failed to fetch accuracy leaderboard: ${e.message}'));
    } catch (e, stackTrace) {
      _logger.e('Error fetching accuracy leaderboard: $e', e, stackTrace);
      final cachedFaculties = await _getFacultiesFromLocal();
      if (cachedFaculties.isNotEmpty) {
        _logger.w(
            'Remote fetch failed, returning cached accuracy leaderboard as fallback.');
        return Right(_mapModelsToEntries(cachedFaculties));
      }
      return Left(ServerFailure(
          'Failed to fetch accuracy leaderboard: ${e.toString()}'));
    }
  }
}
