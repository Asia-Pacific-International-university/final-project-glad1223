import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/api_client.dart'; // Assuming you have an ApiClient
import '../models/user_model.dart'; // Assuming you have a UserModel

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient; // Inject your API client

  UserRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Assuming your API client has a method to fetch the current user's data
      final userData = await _apiClient
          .get('/users/me'); // Replace with your actual API endpoint
      final userModel =
          UserModel.fromJson(userData); // Convert JSON to UserModel
      final userEntity =
          userModel.toDomain(); // Convert UserModel to User entity
      return Right(userEntity);
    } catch (e) {
      // Handle different types of exceptions and map them to Failures
      return Left(ServerFailure()); // Generic server failure for now
    }
  }

  // Implement other methods from UserRepository if needed
}
