// lib/data/datasources/remote/leaderboard_remote_datasource.dart
import 'package:final_project/data/models/faculty_model.dart';

abstract class LeaderboardRemoteDataSource {
  Stream<List<FacultyModel>> getFacultyLeaderboardStream();
  Future<List<FacultyModel>> getFacultyLeaderboardSnapshot();

  // ADD THESE NEW DECLARATIONS:
  Stream<List<FacultyModel>> getFastestCompletionLeaderboardStream();
  Stream<List<FacultyModel>> getAccuracyLeaderboardStream();
}
