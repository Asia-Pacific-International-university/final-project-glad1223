// lib/domain/repositories/user_repositories.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart'; // Assuming your User entity is here
import '../../core/error/failures.dart'; // Assuming your Failure classes are here

abstract class UserRepository {
  /// Gets the currently authenticated user's profile.
  /// Fetches from local cache first, then remote if needed.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Fetches a user's profile by ID.
  /// Fetches from local cache first, then remote if needed.
  Future<Either<Failure, User?>> getUserProfile(String userId);

  /// Updates a user's faculty ID.
  /// Updates remote source and then local cache.
  Future<Either<Failure, User>> updateUserFaculty(
      String userId, String facultyId);

  /// Updates a user's total points.
  /// Updates remote source and then local cache.
  Future<Either<Failure, User>> updateUserTotalPoints(
      String userId, int newTotalPoints);

  /// Adds badges to a user's profile.
  /// Updates remote source and then local cache.
  Future<Either<Failure, User>> addUserBadges(
      String userId, List<String> badgesToAdd);

  // Add other methods as needed, e.g., update username, email (if allowed)
}
