import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repositories.dart';

class AddUserBadgesUseCase implements UseCase<User, AddUserBadgesParams> {
  final UserRepositories userRepository;

  AddUserBadgesUseCase({required this.userRepository});

  @override
  Future<Either<Failure, User>> call(AddUserBadgesParams params) async {
    return await userRepository.addUserBadges(
        params.userId, params.badgesToAdd);
  }
}

class AddUserBadgesParams {
  final String userId;
  final List<String> badgesToAdd;

  AddUserBadgesParams({required this.userId, required this.badgesToAdd});
}
