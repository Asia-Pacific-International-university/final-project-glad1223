import 'package:equatable/equatable.dart'; // Consider using equatable for easier object comparison

enum QuestType {
  trivia,
  poll,
  locationCheckIn,
  photoChallenge,
  miniPuzzle,
}

class Quest extends Equatable {
  final String? id;
  final QuestType? type;
  final String? question; // For trivia, polls, puzzles
  final List<String>? options; // For trivia, polls
  final String? correctAnswer; // For trivia, puzzles
  final String? locationName; // For location check-in
  final double? latitude; // For location check-in
  final double? longitude; // For location check-in
  final String? photoTheme; // For photo challenge
  final int? timeLimitSeconds;
  final DateTime? startTime;

  Quest({
    this.id,
    this.type,
    this.question,
    this.options,
    this.correctAnswer,
    this.locationName,
    this.latitude,
    this.longitude,
    this.photoTheme,
    this.timeLimitSeconds,
    this.startTime,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        question,
        options,
        correctAnswer,
        locationName,
        latitude,
        longitude,
        photoTheme,
        timeLimitSeconds,
        startTime,
      ];
}
