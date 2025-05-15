// *** lib/domain/usecases/sign_in_usecase.dart ***
import 'package:dartz/dartz.dart';
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart'
    as lcqw; // Added prefix 'lcqw'
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart'; // Keep this import
import '../../core/usecases/usecase.dart';

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(params.email, params.password);
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}
