// lib/core/usecases/usecase.dart
//import 'package:dartz/dartz.dart';

abstract class NoParamStreamUseCase<T> {
  Stream<T> call();
}

abstract class NoParamFutureUseCase<T> {
  Future<T> call();
}

abstract class ParamFutureUseCase<Params, Result> {
  Future<Result> call(Params params);
}

abstract class ParamStreamUseCase<Params, Result> {
  Stream<Result> call(Params params);
}
