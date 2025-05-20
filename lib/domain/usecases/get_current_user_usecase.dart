import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repositories.dart'; // Use UserRepository to get current user profile

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final UserRepositories userRepository;

  GetCurrentUserUseCase({required this.userRepository});

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    // The UserRepository's getCurrentUser method already handles fetching from local/remote
    return await userRepository.getCurrentUser();
  }
}
