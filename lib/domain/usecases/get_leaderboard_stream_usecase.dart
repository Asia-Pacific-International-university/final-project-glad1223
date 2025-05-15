//import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/entities/leaderboard_entry.dart';
import 'package:final_project/domain/repositories/leaderboard_repositories.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart'; // Import Either for handling Failure
import 'dart:async';

// *** lib/core/usecases/usecase.dart ***
abstract class NoParamStreamUseCase<T> {
  Stream<T> call();
}

abstract class NoParamFutureUseCase<T> {
  Future<T> call();
}

abstract class ParamFutureUseCase<Params, Result> {
  Future<Either<Failure, Result>> call(Params params);
}

abstract class ParamStreamUseCase<Params, Result> {
  Stream<Either<Failure, Result>> call(Params params);
}

// *** lib/domain/usecases/get_leaderboard_stream_usecase.dart ***
class GetLeaderboardStreamUseCase
    implements NoParamStreamUseCase<Either<Failure, List<LeaderboardEntry>>> {
  // Updated the type parameter
  final LeaderboardRepositories _leaderboardRepository;

  GetLeaderboardStreamUseCase(
      {required LeaderboardRepositories leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository;

  @override
  Stream<Either<Failure, List<LeaderboardEntry>>> call() {
    // Updated the return type
    return _leaderboardRepository.getLeaderboardStream();
  }
}
