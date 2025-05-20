import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repositories.dart';

class UpdateUserPointsUseCase implements UseCase<User, UpdateUserPointsParams> {
  final UserRepositories userRepository;

  UpdateUserPointsUseCase({required this.userRepository});

  @override
  Future<Either<Failure, User>> call(UpdateUserPointsParams params) async {
    return await userRepository.updateUserTotalPoints(
        params.userId, params.newTotalPoints);
  }
}

class UpdateUserPointsParams {
  final String userId;
  final int newTotalPoints;

  UpdateUserPointsParams({required this.userId, required this.newTotalPoints});
}
