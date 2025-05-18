import 'package:final_project/data/models/quest_model.dart'; // Ensure this import is correct

abstract class QuestRemoteDataSource {
  Future<QuestModel?> getActiveQuest();
  Future<String> submitTriviaAnswer(
      String questId, String answer); // Changed to Future<String>
  Future<void> submitPollVote(String questId, String optionId);
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<String> uploadPhoto(String questId, String imagePath);
  // Add other quest type submission methods if needed
}
