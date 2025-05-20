import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart'; // Import your User entity
import '../../domain/repositories/user_repositories.dart'; // Import the abstract repository
import '../../core/error/failures.dart'; // Import your Failure classes
import '../datasources/remote/auth_remote_datasource.dart'; // Using AuthRemoteDataSource for user data interaction
// import '../datasources/remote/user_remote_datasource.dart'; // Alternative: if you create a dedicated UserRemoteDataSource
import '../datasources/local/user_local_datasource.dart'; // Import the new UserLocalDataSource
// import '../datasources/local/shared_preferences_service.dart'; // No longer needed for user data caching
import '../models/user_model.dart'; // Import your UserModel
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for temporary direct Firestore access

// ========================================================================
// USER REPOSITORY IMPLEMENTATION
// Handles coordinating data access from remote (Firestore via AuthDataSource)
// and local (SQLite via UserLocalDataSource) sources for User data.
// Implements caching logic.
// ========================================================================
class UserRepositoryImpl implements UserRepository {
  // Using AuthRemoteDataSource as it currently contains user data methods.
  // If you create a separate UserRemoteDataSource, replace this dependency.
  final AuthRemoteDataSource _remoteDataSource;

  // Dependency on the new SQLite UserLocalDataSource
  final UserLocalDataSource _localDataSource;

  UserRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required UserLocalDataSource
        localDataSource, // Now depends on UserLocalDataSource
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // --- Helper method to save user data to local cache (delegates to local data source) ---
  Future<void> _saveUserToLocal(UserModel user) async {
    await _localDataSource.saveUser(user);
    print('UserModel ${user.id} saved/updated in SQLite cache');
  }

  // --- Helper method to get user data from local cache (delegates to local data source) ---
  Future<UserModel?> _getUserFromLocal(String userId) async {
    // TODO: Implement staleness check here if needed (e.g., store timestamp in DB)
    return await _localDataSource.getUser(userId);
  }

  // --- Helper method to clear local user cache (delegates to local data source) ---
  Future<void> _clearLocalUser(String userId) async {
    await _localDataSource.clearUser(userId);
    print('UserModel $userId cleared from SQLite cache');
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // 1. Get the current authenticated user ID from the remote source (Firebase Auth)
      // This is the most reliable way to know *who* is logged in.
      final firebaseUser =
          await _remoteDataSource.getCurrentUser(); // This returns UserModel?

      if (firebaseUser == null) {
        // No authenticated user, clear local cache and return null
        print('No current user found remotely. Clearing local cache.');
        // TODO: Clear the specific cached user if you know their ID, or clear all users if simpler
        // await _clearLocalUser('some_id'); // Need a way to know which user was cached
        await _localDataSource
            .clearAllUsers(); // Simple approach: clear all cached users on logout/no user
        return const Right(null);
      }

      final userId = firebaseUser.id;

      // 2. Try to get the user's full profile from local cache first using the ID
      final cachedUser = await _getUserFromLocal(userId);
      if (cachedUser != null) {
        print('Returning current user from local cache');
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
        print('Current user profile $userId not found remotely');
        // This is an unexpected scenario if Firebase Auth returned a user but Firestore doc is missing
        // You might want to log this error or handle it specifically.
        await _localDataSource
            .clearUser(userId); // Clear potentially incomplete local data
        return Left(
            ServerFailure(message: 'User profile data missing in backend.'));
      }

      final userData = userDoc.data();
      if (userData == null) {
        print('Current user profile data for $userId is null remotely');
        await _localDataSource
            .clearUser(userId); // Clear potentially incomplete local data
        return Left(
            ServerFailure(message: 'User profile data is null in backend.'));
      }

      // Convert Firestore data to UserModel
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        print(
            "Error getting current user role for $userId, defaulting to user.");
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
      print('Returning current user from remote source and cached locally');
      return Right(remoteUser.toDomain()); // Assuming UserModel has toDomain()
    } catch (e) {
      print('Error getting current user: $e');
      // If remote fetch fails, you might still want to try returning cached data
      // if you didn't do it in step 2.
      // For robustness, if remote fails, try local one last time before returning failure.
      final userIdFromAuth =
          _remoteDataSource.getCurrentUser()?.id; // Try to get ID again
      if (userIdFromAuth != null) {
        final cachedUserOnError = await _getUserFromLocal(userIdFromAuth);
        if (cachedUserOnError != null) {
          print('Remote fetch failed, returning cached user as fallback.');
          return Right(cachedUserOnError.toDomain());
        }
      }
      return Left(ServerFailure(
          message: 'Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getUserProfile(String userId) async {
    try {
      // 1. Try to get user from local cache first
      final cachedUser = await _getUserFromLocal(userId);
      if (cachedUser != null) {
        print('Returning user profile $userId from local cache');
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
        print('User profile $userId not found remotely');
        return const Right(null); // User not found is a valid case
      }

      final userData = userDoc.data();
      if (userData == null) {
        print('User profile data for $userId is null remotely');
        return const Right(null);
      }

      // Convert Firestore data to UserModel
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        print("Error getting user role for $userId, defaulting to user.");
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
      print(
          'Returning user profile $userId from remote source and cached locally');
      return Right(remoteUser.toDomain()); // Assuming UserModel has toDomain()
    } catch (e) {
      print('Error getting user profile $userId: $e');
      return Left(ServerFailure(
          message: 'Failed to get user profile: ${e.toString()}'));
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

      print(
          'User $userId faculty updated to $facultyId remotely and cached locally');
      return Right(
          updatedUserModel.toDomain()); // Return the updated User entity
    } catch (e) {
      print('Error updating user $userId faculty: $e');
      // Handle specific exceptions from AuthRemoteDataSource if needed
      return Left(ServerFailure(
          message: 'Failed to update user faculty: ${e.toString()}'));
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
      print(
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
              message: 'Failed to retrieve user after points update.'));
        }
        print(
            'User $userId points updated remotely and profile refetched/cached');
        return Right(updatedUser); // Return the updated User entity
      });
    } catch (e) {
      print('Error updating user $userId points: $e');
      return Left(ServerFailure(
          message: 'Failed to update user points: ${e.toString()}'));
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
      print(
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
              message: 'Failed to retrieve user after badge update.'));
        }
        print(
            'User $userId badges updated remotely and profile refetched/cached');
        return Right(updatedUser); // Return the updated User entity
      });
    } catch (e) {
      print('Error adding badges $badgesToAdd to user $userId: $e');
      return Left(
          ServerFailure(message: 'Failed to add user badges: ${e.toString()}'));
    }
  }

  // TODO: Add other UserRepository method implementations here
}

// --- Assuming these helper/interface definitions exist in your project ---
// Import these from your core/error and domain/entities directories

// abstract class Failure { final String message; const Failure({required this message}); }
// class ServerFailure extends Failure { const ServerFailure({String? message}) : super(message: message ?? 'Server Error'); }
// class UserNotFoundException extends ServerException { const UserNotFoundException(String message) : super(message); } // Assuming ServerException exists
// class AuthenticationException extends Failure { const AuthenticationException(String message) : super(message); }

// enum UserRole { user, admin }
// extension UserRoleExtension on UserRole { String get name => toString().split('.').last; }
// UserRole? userRoleFromString(String? roleName) { ... } // Helper function (provided in UserModel)

// class User { final String id; final String email; final String username; final UserRole role; final String? facultyId; final String? facultyName; final int? totalPoints; final List<String> badges; User({required this.id, required this.email, required this.username, required this.role, this.facultyId, this.facultyName, this.totalPoints, this.badges = const []}); }

// class UserModel extends User { UserModel({required super.id, required super.email, required super.username, required super.role, super.facultyId, super.totalPoints, super.badges}); factory UserModel.fromJson(Map<String, dynamic> json) { ... } Map<String, dynamic> toJson() { ... } User toDomain() => User(...); }

// abstract class AuthRemoteDataSource { Future<UserModel> signUpWithEmailAndPassword({required String email, required String password, required String username, required String? facultyId, required UserRole role}); Future<UserModel> signInWithEmailAndPassword({required String email, required String password}); Future<void> signOut(); Future<UserModel?> getCurrentUser(); Future<UserModel> updateUserFaculty({required String userId, required String facultyId}); }

// abstract class UserLocalDataSource { Future<void> saveUser(UserModel user); Future<UserModel?> getUser(String userId); Future<void> clearUser(String userId); Future<void> clearAllUsers(); } // Defined above
