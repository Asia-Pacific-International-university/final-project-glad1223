import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/data/models/quest_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestRemoteDataSourceImpl implements QuestRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'YOUR_BACKEND_BASE_URL'; // Replace with your actual base URL

  QuestRemoteDataSourceImpl({required this.client});

  @override
  Future<QuestModel?> getActiveQuest() async {
    final response = await client.get(Uri.parse('$baseUrl/quests/active'));
    if (response.statusCode == 200) {
      if (response.body.isEmpty)
        return null; // Handle empty response body gracefully
      final json = jsonDecode(response.body);
      return QuestModel.fromJson(json);
    } else if (response.statusCode == 204) {
      // 204 No Content
      return null;
    } else {
      throw Exception(
          'Failed to load active quest. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<String> submitTriviaAnswer(String questId, String answer) async {
    // Changed to Future<String>
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/trivia'),
      body: {'answer': answer}, // Ensure your backend expects this format
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Check for success (200 OK or 201 Created)
      // Assuming the backend returns a JSON with a message or the response body is the string itself
      // If backend returns JSON:
      // final Map<String, dynamic> responseData = jsonDecode(response.body);
      // return responseData['message'] as String; // Or any relevant string field
      // If backend returns a plain string or you want to provide a generic success message:
      return response.body.isNotEmpty
          ? response.body
          : "Trivia answer submitted successfully.";
    } else {
      throw Exception(
          'Failed to submit trivia answer. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<void> submitPollVote(String questId, String optionId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/poll'),
      body: {'option_id': optionId},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to submit poll vote. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude) async {
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/location'),
      body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString()
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to submit location. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  @override
  Future<String> uploadPhoto(String questId, String imagePath) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/quests/$questId/photo'));
    request.files.add(await http.MultipartFile.fromPath(
        'image', imagePath)); // 'image' is the field name
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      // Adjust 'imageUrl' based on your actual backend response structure
      if (json['imageUrl'] != null) {
        return json['imageUrl'] as String;
      } else {
        throw Exception(
            'imageUrl not found in response. Body: ${response.body}');
      }
    } else {
      throw Exception(
          'Failed to upload photo. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
