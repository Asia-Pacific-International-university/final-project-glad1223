import 'package:final_project/data/datasources/remote/quest_remote_datasource.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
//import 'package:final_project/data/models/quest_model.dart'; // Assuming QuestModel is in this path

class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remoteDataSource;

  QuestRepositoryImpl({required QuestRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Quest?> getActiveQuest() async {
    final questModel = await _remoteDataSource.getActiveQuest();
    return questModel?.toDomain();
  }

  @override
  Future<void> submitTriviaAnswer(String questId, String answer) async {
    await _remoteDataSource.submitTriviaAnswer(questId, answer);
  }

  @override
  Future<void> submitPollVote(String questId, String optionId) async {
    await _remoteDataSource.submitPollVote(questId, optionId);
  }

  @override
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude) async {
    await _remoteDataSource.submitCheckInLocation(questId, latitude, longitude);
  }

  @override
  Future<void> uploadPhoto(String questId, String imagePath) async {
    await _remoteDataSource.uploadPhoto(questId, imagePath);
  }

  // Implement other submit methods
}
