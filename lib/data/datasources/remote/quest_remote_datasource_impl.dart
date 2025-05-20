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
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/trivia'),
      headers: {'Content-Type': 'application/json'}, // Specify content type
      body: jsonEncode({'answer': answer}), // Encode body as JSON
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
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
      headers: {'Content-Type': 'application/json'}, // Specify content type
      body: jsonEncode({'option_id': optionId}), // Encode body as JSON
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
      headers: {'Content-Type': 'application/json'}, // Specify content type
      body: jsonEncode({
        'latitude': latitude.toString(),
        'longitude': longitude.toString()
      }), // Encode body as JSON
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

  @override
  Future<void> submitMiniPuzzleAnswer(String questId, String answer) async {
    // This is a placeholder. Implement actual API call if your backend supports it.
    print(
        'QuestRemoteDataSourceImpl: Simulating mini-puzzle answer submission for $questId with answer $answer');
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    // For now, assume success. In a real app, you'd make an http call.
    // final response = await client.post(
    //   Uri.parse('$baseUrl/quests/$questId/mini-puzzle'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'answer': answer}),
    // );
    // if (response.statusCode != 200 && response.statusCode != 204) {
    //   throw Exception('Failed to submit mini-puzzle answer: ${response.body}');
    // }
  }
}
