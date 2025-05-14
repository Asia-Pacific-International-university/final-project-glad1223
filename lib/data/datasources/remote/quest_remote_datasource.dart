import 'package:final_project/data/models/quest_model.dart';

abstract class QuestRemoteDataSource {
  Future<QuestModel?> getActiveQuest();
  Future<void> submitTriviaAnswer(String questId, String answer);
  Future<void> submitPollVote(String questId, String optionId);
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<String> uploadPhoto(
      String questId, String imagePath); // Returns URL or identifier
  // Add methods for other quest types as needed
}
