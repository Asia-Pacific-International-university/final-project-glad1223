import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../data/models/user_model.dart'; // Import UserModel
import '../entities/user.dart'; // Import User entity
import '../repositories/auth_repository.dart';
import '../repositories/user_repositories.dart'; // Import UserRepository

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository authRepository;
  final UserRepositories userRepository; // Added UserRepository

  SignUpUseCase({
    required this.authRepository,
    required this.userRepository, // Initialize UserRepository
  });

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // First, sign up the user with Firebase Authentication
    final authResult = await authRepository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      username:
          params.username, // Passed to auth for initial user model creation
      facultyId: params.facultyId,
      role: params.role,
    );

    return authResult.fold(
      (failure) => Left(failure), // If auth fails, return the failure
      (userModel) async {
        // If auth succeeds, the AuthRemoteDataSourceImpl already created the Firestore user document.
        // We just need to ensure the returned UserModel is converted to a User entity.
        return Right(userModel.toDomain());
      },
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String username;
  final UserRole role;
  final String? facultyId;

  SignUpParams({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
    this.facultyId,
  });
}
