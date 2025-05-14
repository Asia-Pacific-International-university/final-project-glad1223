import 'package:final_project/domain/entities/quest.dart';

abstract class QuestRepository {
  Future<Quest?> getActiveQuest();
  Future<void> submitTriviaAnswer(String questId, String answer);
  Future<void> submitPollVote(String questId, String optionId);
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude);
  Future<void> uploadPhoto(String questId, String imagePath);
  // Add methods for other quest types
}
