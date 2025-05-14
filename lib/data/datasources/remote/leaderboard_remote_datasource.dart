import 'package:final_project/data/models/faculty_model.dart';

abstract class LeaderboardRemoteDataSource {
  Stream<List<FacultyModel>> getFacultyLeaderboardStream();
  Future<List<FacultyModel>> getFacultyLeaderboardSnapshot();
}
