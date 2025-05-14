import 'auth_remote_datasource.dart';
import 'package:final_project/data/models/user_model.dart';
import 'api_client.dart'; // Assuming you have an ApiClient

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> signUp(
      String username, String email, String password, String faculty) async {
    final response = await _apiClient.post('/auth/signup', body: {
      'username': username,
      'email': email,
      'password': password,
      'faculty': faculty,
    });
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response);
  }

  @override
  Future<void> signOut() async {
    await _apiClient
        .post('/auth/logout', body: {}); // Or however your API handles logout
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final response =
        await _apiClient.get('/auth/me'); // Endpoint to get current user
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }
}
