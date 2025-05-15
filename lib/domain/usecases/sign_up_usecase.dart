import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart'; // Import Usecase

class SignUpParams {
  final String username;
  final String email;
  final String password;
  final String faculty;

  SignUpParams({
    required this.username,
    required this.email,
    required this.password,
    required this.faculty,
  });
}

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await _authRepository.signUp(
      params.username,
      params.email,
      params.password,
      params.faculty,
    );
  }
}
