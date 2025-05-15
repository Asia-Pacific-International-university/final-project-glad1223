// lib/domain/repositories/user_repositories.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class UserRepositories {
  // Corrected abstract class name
  Future<Either<Failure, User>> getUser(String userId); // Added getUser
  Future<Either<Failure, User>> getCurrentUser();
  // Add other user-related methods as needed, e.g., updateProfile
}
