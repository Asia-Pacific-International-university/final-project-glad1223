import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/datasources/remote/leaderboard_remote_datasource.dart';
import 'package:final_project/data/models/faculty_model.dart';

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FacultyModel>> getFacultyLeaderboardStream() {
    return _firestore
        .collection(
            'faculties') // Replace 'faculties' with your actual collection name
        .orderBy('points', descending: true) // Order by points
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FacultyModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<List<FacultyModel>> getFacultyLeaderboardSnapshot() async {
    final snapshot = await _firestore
        .collection(
            'faculties') // Replace 'faculties' with your actual collection name
        .orderBy('points', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FacultyModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
