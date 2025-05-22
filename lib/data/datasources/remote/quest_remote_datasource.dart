import 'package:final_project/data/models/quest_model.dart';

abstract class QuestRemoteDataSource {
  Future<QuestModel?> getActiveQuest();
  Future<String> submitTriviaAnswer(String questId, String answer);
  Future<void> submitPollVote(String questId, String optionId); // Added
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<String> uploadPhoto(String questId, String imagePath);
  Future<void> submitMiniPuzzleAnswer(String questId, String answer); // Added
}
