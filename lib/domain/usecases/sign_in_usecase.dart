import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart'; // Import User entity
import '../repositories/auth_repository.dart';
import '../repositories/user_repositories.dart'; // Import UserRepository

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository authRepository;
  final UserRepositories userRepository; // Added UserRepository

  SignInUseCase({
    required this.authRepository,
    required this.userRepository, // Initialize UserRepository
  });

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // First, sign in the user with Firebase Authentication
    final authResult = await authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    return authResult.fold(
      (failure) => Left(failure), // If auth fails, return the failure
      (userModel) async {
        // If auth succeeds, fetch the full user profile from the UserRepository
        // The UserModel from authRepository already contains the necessary profile data
        // because AuthRemoteDataSourceImpl fetches it from Firestore during signIn.
        return Right(userModel.toDomain());
      },
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}
