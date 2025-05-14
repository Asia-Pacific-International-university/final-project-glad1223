import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class UserRepositories {
  Future<Either<Failure, User>> getCurrentUser();
  // Add other user-related methods as needed, e.g., updateProfile
}
