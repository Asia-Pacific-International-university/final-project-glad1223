import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/data/models/quest_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class QuestRemoteDataSourceImpl implements QuestRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'YOUR_BACKEND_BASE_URL'; // Replace with your actual base URL

  QuestRemoteDataSourceImpl({required this.client});

  @override
  Future<QuestModel?> getActiveQuest() async {
    final response = await client.get(Uri.parse('$baseUrl/quests/active'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return QuestModel.fromJson(json);
    } else if (response.statusCode == 204) {
      return null; // No active quest
    } else {
      throw Exception('Failed to load active quest');
    }
  }

  @override
  Future<void> submitTriviaAnswer(String questId, String answer) async {
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/trivia'),
      body: {'answer': answer},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit trivia answer');
    }
  }

  @override
  Future<void> submitPollVote(String questId, String optionId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/quests/$questId/poll'),
      body: {'option_id': optionId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit poll vote');
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
    if (response.statusCode != 200) {
      throw Exception('Failed to submit location');
    }
  }

  @override
  Future<String> uploadPhoto(String questId, String imagePath) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/quests/$questId/photo'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['imageUrl']; // Adjust based on your backend response
    } else {
      throw Exception('Failed to upload photo');
    }
  }

  // Add implementations for other quest types
}
