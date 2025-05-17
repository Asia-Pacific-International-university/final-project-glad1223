import 'package:final_project/core/error/failures.dart'; // Import your custom failure class
import 'package:dartz/dartz.dart';

class InvalidInputFailure extends Failure {
  @override
  final String message; // Made non-nullable

  const InvalidInputFailure({required this.message})
      : super(message: message); // Made required

  @override
  List<Object?> get props => [message];
}

class ValidateInputUseCase {
  Either<Failure, String> execute(String input) {
    if (input.trim().isEmpty) {
      return Left(InvalidInputFailure(message: 'Input cannot be empty.'));
    }
    return Right(input.trim());
  }
}
