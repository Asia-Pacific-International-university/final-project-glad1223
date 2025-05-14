import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/error/failures.dart';

abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint,
      {required Map<String, dynamic> body});
  // ... other abstract methods ...
  Future<Map<String, dynamic>> put(String path, {dynamic body});
  Future<Map<String, dynamic>> delete(String path);

  // For real-time updates (e.g., Leaderboard)
  Stream<dynamic> getLeaderboardStream(
      String path); // Adjust return type based on your backend
}

// Example implementation using the http package (you'll need to import it)
class HttpApiClient implements ApiClient {
  final String _baseUrl =
      'YOUR_API_BASE_URL'; // Replace with your actual base URL
  final http.Client _client = http.Client();

  @override
  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$path'));
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> post(String path, {dynamic body}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> put(String path, {dynamic body}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$path'));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw UnauthorizedFailure();
    } else if (response.statusCode == 404) {
      throw NotFoundFailure();
    } else {
      throw ServerFailure('Server error: ${response.statusCode}');
    }
  }

  @override
  Stream<dynamic> getLeaderboardStream(String path) {
    // Implement your stream logic here (e.g., using WebSockets)
    throw UnimplementedError('Leaderboard stream not implemented');
  }
}
