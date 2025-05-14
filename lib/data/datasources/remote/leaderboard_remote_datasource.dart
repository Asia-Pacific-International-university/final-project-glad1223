import 'package:final_project/data/models/faculty_model.dart';

abstract class LeaderboardRemoteDataSource {
  // This method should return a stream of faculty data that includes their points.
  Stream<List<FacultyModel>> getFacultyLeaderboardStream();
}
