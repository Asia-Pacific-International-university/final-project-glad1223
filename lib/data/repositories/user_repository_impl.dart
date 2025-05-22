import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart'; // Import the logger package
import '../../domain/entities/user.dart'; // Import your User entity
import '../../domain/repositories/user_repositories.dart'; // Import the abstract repository
import '../../core/error/failures.dart'; // Import your Failure classes
import '../datasources/remote/auth_remote_datasource.dart'; // Using AuthRemoteDataSource for user data interaction
import '../datasources/local/user_local_datasource.dart'; // Import the new UserLocalDataSource
import '../models/user_model.dart'; // Import your UserModel
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for temporary direct Firestore access
// import 'package:final_project/core/services/notification_service.dart'; // This import seems unused here, consider removing it if it's not used.

// ========================================================================
// USER REPOSITORY IMPLEMENTATION
// Handles coordinating data access from remote (Firestore via AuthDataSource)
// and local (SQLite via UserLocalDataSource) sources for User data.
// Implements caching logic.
// ========================================================================
class UserRepositoryImpl implements UserRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final Logger _logger; // Logger instance

  UserRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required UserLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _logger = Logger(
          // Initialize logger
          printer: PrettyPrinter(
            methodCount:
                0, // No method calls to be displayed for repository logs
            errorMethodCount:
                5, // Number of method calls if stacktrace is provided
            lineLength: 120, // Width of the output
            colors: true, // Colorful log messages
            printEmojis: true, // Print emojis
            printTime: false, // Should each log print a timestamp
          ),
        );

  // --- Helper method to save user data to local cache (delegates to local data source) ---
  Future<void> _saveUserToLocal(UserModel user) async {
    await _localDataSource.saveUser(user);
    _logger.i('UserModel ${user.id} saved/updated in SQLite cache');
  }

  // --- Helper method to get user data from local cache (delegates to local data source) ---
  Future<UserModel?> _getUserFromLocal(String userId) async {
    // TODO: Implement staleness check here if needed (e.g., store timestamp in DB)
    return await _localDataSource.getUser(userId);
  }

  // Removed _clearLocalUser as it was unreferenced and clearAllUsers is used instead.
  // If you need specific user clearing, re-add this method and call it where appropriate.
  /*
  Future<void> _clearLocalUser(String userId) async {
    await _localDataSource.clearUser(userId);
    _logger.i('UserModel $userId cleared from SQLite cache');
  }
  */

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // 1. Get the current authenticated user ID from the remote source (Firebase Auth)
      // This is the most reliable way to know *who* is logged in.
      final firebaseUser =
          await _remoteDataSource.getCurrentUser(); // This returns UserModel?

      if (firebaseUser == null) {
        // No authenticated user, clear local cache and return null
        _logger.i('No current user found remotely. Clearing local cache.');
        await _localDataSource
            .clearAllUsers(); // Simple approach: clear all cached users on logout/no user
        return const Right(null);
      }

      final userId = firebaseUser.id;

      // 2. Try to get the user's full profile from local cache first using the ID
      final cachedUser = await _getUserFromLocal(userId);
      if (cachedUser != null) {
        _logger.i('Returning current user from local cache');
        return Right(
            cachedUser.toDomain()); // Assuming UserModel has toDomain()
      }

      // 3. If not in cache, fetch the full profile from remote (Firestore)
      // Using temporary direct Firestore access as getUserById is not in AuthRemoteDataSource
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _logger.w('Current user profile $userId not found remotely');
        // This is an unexpected scenario if Firebase Auth returned a user but Firestore doc is missing
        // You might want to log this error or handle it specifically.
        await _localDataSource
            .clearUser(userId); // Clear potentially incomplete local data
        return Left(
            ServerFailure('User profile data missing in backend.')); // Fixed
      }

      final userData = userDoc.data();
      if (userData == null) {
        _logger.e('Current user profile data for $userId is null remotely');
        await _localDataSource
            .clearUser(userId); // Clear potentially incomplete local data
        return Left(
            ServerFailure('User profile data is null in backend.')); // Fixed
      }

      // Convert Firestore data to UserModel
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        _logger.w(
            "Error getting current user role for $userId, defaulting to user: $e");
        userRole = UserRole.user;
      }

      final remoteUser = UserModel(
        id: userId,
        email: userData['email'] ??
            '', // Email might not be stored in user doc if only auth has it
        username: userData['username'] ?? '',
        role: userRole,
        facultyId: userData['facultyId'],
        totalPoints: userData['totalPoints'],
        badges: List<String>.from(userData['badges'] ?? []),
      );

      // 4. If fetched from remote, save to local cache
      await _saveUserToLocal(remoteUser);
      _logger.i('Returning current user from remote source and cached locally');
      return Right(remoteUser.toDomain()); // Assuming UserModel has toDomain()
    } catch (e, stackTrace) {
      _logger.e('Error getting current user: $e', e, stackTrace);
      // If remote fetch fails, you might still want to try returning cached data
      // if you didn't do it in step 2.
      // For robustness, if remote fails, try local one last time before returning failure.
      final firebaseUserOnAuthError =
          await _remoteDataSource.getCurrentUser(); // Try to get ID again
      if (firebaseUserOnAuthError != null) {
        final cachedUserOnError =
            await _getUserFromLocal(firebaseUserOnAuthError.id);
        if (cachedUserOnError != null) {
          _logger.w('Remote fetch failed, returning cached user as fallback.');
          return Right(cachedUserOnError.toDomain());
        }
      }
      return Left(ServerFailure(
          'Failed to get current user: ${e.toString()}')); // Fixed
    }
  }

  @override
  Future<Either<Failure, User?>> getUserProfile(String userId) async {
    try {
      // 1. Try to get user from local cache first
      final cachedUser = await _getUserFromLocal(userId);
      if (cachedUser != null) {
        _logger.i('Returning user profile $userId from local cache');
        return Right(
            cachedUser.toDomain()); // Assuming UserModel has toDomain()
      }

      // 2. If not in cache, fetch from remote (Firestore via AuthDataSource or a dedicated UserDataSource)
      // Using temporary direct Firestore access as getUserById is not in AuthRemoteDataSource
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _logger.w('User profile $userId not found remotely');
        return const Right(null); // User not found is a valid case
      }

      final userData = userDoc.data();
      if (userData == null) {
        _logger.e('User profile data for $userId is null remotely');
        return const Right(null);
      }

      // Convert Firestore data to UserModel
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        _logger
            .w("Error getting user role for $userId, defaulting to user: $e");
        userRole = UserRole.user;
      }

      final remoteUser = UserModel(
        id: userId,
        email: userData['email'] ??
            '', // Email might not be stored in user doc if only auth has it
        username: userData['username'] ?? '',
        role: userRole,
        facultyId: userData['facultyId'],
        totalPoints: userData['totalPoints'],
        badges: List<String>.from(userData['badges'] ?? []),
      );

      // 3. If fetched from remote, save to local cache
      await _saveUserToLocal(remoteUser);
      _logger.i(
          'Returning user profile $userId from remote source and cached locally');
      return Right(remoteUser.toDomain()); // Assuming UserModel has toDomain()
    } catch (e, stackTrace) {
      _logger.e('Error getting user profile $userId: $e', e, stackTrace);
      return Left(ServerFailure(
          'Failed to get user profile: ${e.toString()}')); // Fixed
    }
  }

  @override
  Future<Either<Failure, User>> updateUserFaculty(
      String userId, String facultyId) async {
    try {
      // 1. Update the remote source (Firestore via AuthDataSource)
      // Assuming AuthRemoteDataSourceImpl.updateUserFaculty returns the updated UserModel
      final updatedUserModel = await _remoteDataSource.updateUserFaculty(
          userId: userId, facultyId: facultyId);

      // 2. Update the local cache with the new data
      await _saveUserToLocal(updatedUserModel);

      _logger.i(
          'User $userId faculty updated to $facultyId remotely and cached locally');
      return Right(
          updatedUserModel.toDomain()); // Return the updated User entity
    } catch (e, stackTrace) {
      _logger.e('Error updating user $userId faculty: $e', e, stackTrace);
      // Handle specific exceptions from AuthRemoteDataSource if needed
      return Left(ServerFailure(
          'Failed to update user faculty: ${e.toString()}')); // Fixed
    }
  }

  @override
  Future<Either<Failure, User>> updateUserTotalPoints(
      String userId, int newTotalPoints) async {
    try {
      // TODO: Implement updating points in the remote data source (Firestore)
      // You'll likely need a new method in AuthRemoteDataSource or UserRemoteDataSource:
      // Future<UserModel> updateUserPoints(String userId, int newTotalPoints);
      // For now, we'll simulate the update and fetch the user.

      // Simulate updating in Firestore directly (violates layer separation)
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'totalPoints': newTotalPoints,
      });
      _logger.i(
          'Simulated updating points for user $userId to $newTotalPoints in Firestore');

      // After updating remotely, fetch the latest user data
      // This ensures the local cache gets the most up-to-date data, including points,
      // and potentially other fields that might have changed on the backend.
      // We expect getUserProfile to update the local cache internally.
      final updatedUserEither =
          await getUserProfile(userId); // Use the repository's fetch method

      return updatedUserEither.fold(
          (failure) => Left(
              failure), // If fetching after update fails, return that failure
          (updatedUser) {
        if (updatedUser == null) {
          // This case should ideally not happen if the update succeeded
          return Left(ServerFailure(
              'Failed to retrieve user after points update.')); // Fixed
        }
        _logger.i(
            'User $userId points updated remotely and profile refetched/cached');
        return Right(updatedUser); // Return the updated User entity
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating user $userId points: $e', e, stackTrace);
      return Left(ServerFailure(
          'Failed to update user points: ${e.toString()}')); // Fixed
    }
  }

  @override
  Future<Either<Failure, User>> addUserBadges(
      String userId, List<String> badgesToAdd) async {
    try {
      // TODO: Implement adding badges in the remote data source (Firestore)
      // You'll likely need a new method in AuthRemoteDataSource or UserRemoteDataSource:
      // Future<UserModel> addUserBadges(String userId, List<String> badges);
      // For now, we'll simulate the update and fetch the user.

      // Simulate updating in Firestore directly (violates layer separation)
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userDocRef.update({
        'badges': FieldValue.arrayUnion(
            badgesToAdd), // Use arrayUnion to add to the list
      });
      _logger.i(
          'Simulated adding badges $badgesToAdd for user $userId in Firestore');

      // After updating remotely, fetch the latest user data
      // We expect getUserProfile to update the local cache internally.
      final updatedUserEither =
          await getUserProfile(userId); // Use the repository's fetch method

      return updatedUserEither.fold(
          (failure) => Left(
              failure), // If fetching after update fails, return that failure
          (updatedUser) {
        if (updatedUser == null) {
          // This case should ideally not happen if the update succeeded
          return Left(ServerFailure(
              'Failed to retrieve user after badge update.')); // Fixed
        }
        _logger.i(
            'User $userId badges updated remotely and profile refetched/cached');
        return Right(updatedUser); // Return the updated User entity
      });
    } catch (e, stackTrace) {
      _logger.e('Error adding badges $badgesToAdd to user $userId: $e', e,
          stackTrace);
      return Left(
          ServerFailure('Failed to add user badges: ${e.toString()}')); // Fixed
    }
  }

  // TODO: Add other UserRepository method implementations here
}
