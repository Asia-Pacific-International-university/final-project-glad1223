import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/api_client.dart'; // Assuming you have an ApiClient
import '../models/user_model.dart'; // Assuming you have a UserModel

class UserRepositoryImpl implements UserRepositories {
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
      return Left(ServerFailure(
          'Server error: ${e.toString()}')); // Corrected: Passing message as positional argument
    }
  }

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final userData = await _apiClient.get('/users/$userId');
      final userModel = UserModel.fromJson(userData);
      final userEntity = userModel.toDomain();
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(
          'Server error: ${e.toString()}')); // Corrected: Passing message as positional argument
    }
  }

  // Implement other methods from UserRepository if needed
}
