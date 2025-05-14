// *** lib/data/datasources/remote/auth_remote_datasource.dart ***
import '../../../core/error/failures.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp(
      String username, String email, String password, String faculty);
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _apiClient
          .post('/auth/login', body: {'email': email, 'password': password});
      return UserModel.fromJson(response);
    } catch (e) {
      // Handle specific error codes and throw appropriate exceptions/Failures
      throw ServerFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(
      String username, String email, String password, String faculty) async {
    try {
      final response = await _apiClient.post('/auth/signup', body: {
        'username': username,
        'email': email,
        'password': password,
        'faculty': faculty
      });
      return UserModel.fromJson(response);
    } catch (e) {
      // Handle specific error codes
      throw ServerFailure('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _apiClient.post('/auth/logout',
          body: {}); // Or however your logout API is structured
    } catch (e) {
      // Optionally handle logout errors
      print('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/status');
      if (response != null && response is Map<String, dynamic>) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      // If no active session, the API might return an error or null
      return null;
    }
  }
}
