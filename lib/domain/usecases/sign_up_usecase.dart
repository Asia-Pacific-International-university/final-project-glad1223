import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/auth_repositories.dart';
import 'package:final_project/domain/entities/user.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class SignUpUseCase implements FutureUseCase<User, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, User>> execute(SignUpParams params) async {
    return await _authRepository.signUp(
        params.email, params.password, params.faculty);
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String faculty;

  SignUpParams(
      {required this.email, required this.password, required this.faculty});
}
