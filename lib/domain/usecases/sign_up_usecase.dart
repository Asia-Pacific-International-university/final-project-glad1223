import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/auth_repository.dart';
import 'package:final_project/domain/entities/user.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class SignUpUseCase implements ParamFutureUseCase<SignUpParams, User> {
  // Using ParamFutureUseCase
  final AuthRepository _authRepository;

  SignUpUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // Method name is call
    // Assuming _authRepository.signUp takes an additional 'name' parameter.
    // You might need to adjust this based on your actual AuthRepository.
    return await _authRepository.signUp(params.email, params.password,
        params.faculty, ""); // Added a placeholder for name
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String faculty;
  final String name; // Added name

  SignUpParams(
      {required this.email,
      required this.password,
      required this.faculty,
      this.name = ""}); // Added this.name and a default value
}
