import 'package:final_project/core/error/failures.dart'; // Import your custom failure class
import 'package:dartz/dartz.dart';

// Assuming InvalidInputFailure is defined like this:
class InvalidInputFailure extends Failure {
  final String? message; // Made the parameter named and nullable

  InvalidInputFailure({this.message})
      : super(message: message); // Call super constructor

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
