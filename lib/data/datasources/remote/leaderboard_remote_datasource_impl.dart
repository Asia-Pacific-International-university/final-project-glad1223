import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/datasources/remote/leaderboard_remote_datasource.dart';
import 'package:final_project/data/models/faculty_model.dart';

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FacultyModel>> getFacultyLeaderboardStream() {
    return _firestore
        .collection('faculties')
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacultyModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id, // IMPORTANT: Pass the document ID
                }))
            .toList());
  }

  @override
  Future<List<FacultyModel>> getFacultyLeaderboardSnapshot() async {
    final snapshot = await _firestore
        .collection('faculties')
        .orderBy('points', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FacultyModel.fromJson({
              ...(doc.data() as Map<String, dynamic>),
              'id': doc.id, // IMPORTANT: Pass the document ID
            }))
        .toList();
  }

  // --- Optional: Add methods for specific leaderboards ---
  Stream<List<FacultyModel>> getFastestCompletionLeaderboardStream() {
    return _firestore
        .collection('faculties')
        .where('fastestCompletionTimeMs',
            isNull: false) // Only include those with a time
        .orderBy('fastestCompletionTimeMs',
            descending: false) // Lowest time is best
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacultyModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<FacultyModel>> getAccuracyLeaderboardStream() {
    return _firestore
        .collection('faculties')
        .where('totalQuestionsAttempted',
            isGreaterThan: 0) // Only include those who attempted
        .orderBy('totalCorrectAnswers',
            descending: true) // Or calculate ratio and sort
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacultyModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }
}
