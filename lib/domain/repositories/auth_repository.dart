// *** lib/domain/repositories/auth_repositories.dart ***
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/constants/app_constants.dart'; // Import role enum
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId, // Made nullable to align with data layer
    required UserRole role, // Add the role parameter
  });
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>>
      getCurrentUser(); // Check if a user is currently logged in
  // Add method to update user's faculty
  Future<Either<Failure, User>> updateUserFaculty({
    required String userId,
    required String facultyId,
  });
}

// // *** lib/domain/repositories/auth_repositories.dart ***
// import 'package:dartz/dartz.dart';
// import '../entities/user.dart';
// import '../../core/error/failures.dart';

// abstract class AuthRepository {
//   Future<Either<Failure, User>> signUp(
//       String username, String email, String password, String faculty);
//   Future<Either<Failure, User>> signIn(String email, String password);
//   Future<Either<Failure, void>> signOut();
//   Future<Either<Failure, User?>>
//       getCurrentUser(); // Check if a user is currently logged in
// }
