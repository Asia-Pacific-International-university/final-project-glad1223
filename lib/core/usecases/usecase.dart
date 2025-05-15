// *** lib/core/usecases/usecase.dart ***
import 'package:dartz/dartz.dart'; // Import dartz here
import 'package:final_project/core/error/failures.dart';

abstract class NoParamStreamUseCase<T> {
  Stream<Either<Failure, T>> call(); // Use Either
}

abstract class NoParamFutureUseCase<T> {
  Future<Either<Failure, T>> call(); // Use Either
}

abstract class ParamFutureUseCase<Params, Result> {
  Future<Either<Failure, Result>> call(Params params); // Use Either
}

abstract class ParamStreamUseCase<Params, Result> {
  Stream<Either<Failure, Result>> call(Params params); // Use Either
}
