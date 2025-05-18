import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
