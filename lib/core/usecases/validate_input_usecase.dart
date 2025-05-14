import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ValidateInputUseCase {
  Either<Failure, String> execute(String input) {
    if (input.trim().isEmpty) {
      return Left(const Failure(message: 'Input cannot be empty.'));
    }
    return Right(input.trim());
  }
}
