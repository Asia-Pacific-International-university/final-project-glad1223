import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repositories.dart';

class GetUserProfileUseCase implements UseCase<User?, String> {
  final UserRepositories userRepository;

  GetUserProfileUseCase({required this.userRepository});

  @override
  Future<Either<Failure, User?>> call(String userId) async {
    return await userRepository.getUserProfile(userId);
  }
}
