import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ValidateInputUseCase {
  Either<Failure, String> execute(String input) {
    if (input.trim().isEmpty) {
      return const Left(InvalidInputFailure('Input cannot be empty.'));
    }
    return Right(input.trim());
  }
}
