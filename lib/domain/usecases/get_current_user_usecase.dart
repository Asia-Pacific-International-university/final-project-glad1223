import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repositories.dart'; // This import will be fixed to singular 'user_repository'

// --- FIX 1: Define NoParams class if it doesn't exist ---
// You'll need to create a file, for example: 'lib/core/params/no_params.dart'
// and put the following content in it:
//
// class NoParams {
//   const NoParams();
// }
//
// Then, make sure to import it here:
import '../../core/params/no_params.dart'; // <--- ADD THIS IMPORT

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  // --- FIX 2: Correct the type name from UserRepositories to UserRepository ---
  // Based on your previous errors, 'UserRepositories' is undefined.
  // The correct class name should be 'UserRepository' (singular) as per common Dart conventions
  // and the likely name in your 'user_repositories.dart' file.
  final UserRepository userRepository; // Changed from UserRepositories

  GetCurrentUserUseCase({required this.userRepository});

  @override
  // --- FIX 3: Ensure the 'call' method signature matches the UseCase abstract class ---
  // The error "The method doesn't override an inherited method" indicates a mismatch.
  // Assuming UseCase is defined as `abstract class UseCase<Type, Params>`
  // the 'call' method must accept 'Params' as its argument.
  // In this case, 'Params' is 'NoParams'.
  Future<Either<Failure, User?>> call(NoParams params) async {
    // The UserRepository's getCurrentUser method already handles fetching from local/remote
    return await userRepository.getCurrentUser();
  }
}
