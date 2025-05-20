// data/models/faculty_model.dart (or equivalent)
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this import is there

class FacultyModel {
  final String id; // Document ID from Firestore
  final String name;
  int points; // Overall points for main leaderboard
  int totalCorrectAnswers;
  int totalQuestionsAttempted;
  int totalParticipationEvents;
  int?
      fastestCompletionTimeMs; // Nullable, as not all faculties might have completed a timed task
  DateTime? lastActivity; // To track recent participation, nullable initially
  List<String> badges; // List of badge IDs earned by this faculty

  FacultyModel({
    required this.id,
    required this.name,
    this.points = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAttempted = 0,
    this.totalParticipationEvents = 0,
    this.fastestCompletionTimeMs,
    this.lastActivity,
    this.badges = const [],
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as String, // Assumes 'id' is present or passed from doc.id
      name: json['name'] as String,
      points: json['points'] as int? ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      totalQuestionsAttempted: json['totalQuestionsAttempted'] as int? ?? 0,
      totalParticipationEvents: json['totalParticipationEvents'] as int? ?? 0,
      fastestCompletionTimeMs: json['fastestCompletionTimeMs'] as int?,
      lastActivity: (json['lastActivity'] as Timestamp?)?.toDate(),
      badges: List<String>.from(json['badges'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestionsAttempted': totalQuestionsAttempted,
      'totalParticipationEvents': totalParticipationEvents,
      'fastestCompletionTimeMs': fastestCompletionTimeMs,
      'lastActivity':
          lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
      'badges': badges,
    };
  }
}
