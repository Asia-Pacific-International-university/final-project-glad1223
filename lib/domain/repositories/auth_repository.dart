// *** lib/domain/repositories/auth_repositories.dart ***
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUp(
      String username, String email, String password, String faculty);
  Future<Either<Failure, User>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>>
      getCurrentUser(); // Check if a user is currently logged in
}
