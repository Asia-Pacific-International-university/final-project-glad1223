import 'package:equatable/equatable.dart'; // Consider using equatable for easier object comparison

enum QuestType {
  trivia,
  locationCheckIn,
  photoChallenge,
  quickPoll,
  miniPuzzle,
  arHunt,
}

class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final DateTime startTime;
  final DateTime endTime;
  final int pointsAwarded;
  final Map<String, dynamic>?
      data; // Store quest-specific data (e.g., question, options)

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.pointsAwarded,
    this.data,
  });

  @override
  List<Object?> get props =>
      [id, title, description, type, startTime, endTime, pointsAwarded, data];
}
