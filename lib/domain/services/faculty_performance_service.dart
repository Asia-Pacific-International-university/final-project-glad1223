// domain/services/faculty_performance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/models/faculty_model.dart'; // Make sure this path is correct

class FacultyPerformanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to update faculty performance after an event/activity
  Future<void> updateFacultyPerformance({
    required String facultyId,
    required bool isCorrect,
    required int activityDurationMs, // Duration for speed calculation
    required bool participated,
  }) async {
    final facultyRef = _firestore.collection('faculties').doc(facultyId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(facultyRef);

      if (!snapshot.exists) {
        throw Exception("Faculty does not exist!"); // Or create new if desired
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final FacultyModel faculty = FacultyModel.fromJson({
        ...data,
        'id': snapshot.id, // Ensure id is part of the model
      });

      // 1. Update Correctness/Accuracy
      faculty.totalQuestionsAttempted++;
      if (isCorrect) {
        faculty.totalCorrectAnswers++;
        faculty.points += 10; // Award points for correctness
      } else {
        faculty.points += 2; // Minor points for attempting, even if incorrect
      }

      // 2. Update Time/Speed
      if (faculty.fastestCompletionTimeMs == null ||
          activityDurationMs < faculty.fastestCompletionTimeMs!) {
        faculty.fastestCompletionTimeMs = activityDurationMs;
        faculty.points += 5; // Bonus points for setting a new fastest time
      }

      // 3. Update Participation
      if (participated) {
        faculty.totalParticipationEvents++;
        faculty.lastActivity = DateTime.now();
        faculty.points += 3; // Points for participation
      }

      // 4. Award Badges (Logic can be more complex)
      _awardBadges(faculty); // Call a helper method to check and award badges

      // Update the document
      transaction.update(facultyRef, faculty.toJson());
    });
  }

  void _awardBadges(FacultyModel faculty) {
    // Example badge logic:
    if (faculty.totalCorrectAnswers >= 50 &&
        !faculty.badges.contains('accuracy_ace')) {
      faculty.badges.add('accuracy_ace');
      faculty.points += 50; // Bonus points for badge
    }
    if (faculty.fastestCompletionTimeMs != null &&
        faculty.fastestCompletionTimeMs! <= 10000 &&
        !faculty.badges.contains('speed_demon')) {
      faculty.badges.add('speed_demon');
      faculty.points += 75;
    }
    if (faculty.totalParticipationEvents >= 20 &&
        !faculty.badges.contains('active_participant')) {
      faculty.badges.add('active_participant');
      faculty.points += 30;
    }
    // Add more badge logic as needed
  }
}
