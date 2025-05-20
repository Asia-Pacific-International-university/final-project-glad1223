import 'package:equatable/equatable.dart';

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
  final String? title; // Added
  final String? description; // Added
  final String? question;
  final List<String>? options; // For trivia, polls
  final String? correctAnswer;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? photoTheme;
  final int? timeLimitSeconds; // Raw seconds from backend
  final Duration? duration; // Derived Duration
  final DateTime? startTime;

  Quest({
    this.id,
    this.type,
    this.title, // Initialize
    this.description, // Initialize
    this.question,
    this.options,
    this.correctAnswer,
    this.locationName,
    this.latitude,
    this.longitude,
    this.photoTheme,
    this.timeLimitSeconds,
    this.startTime,
  }) : duration = timeLimitSeconds != null
            ? Duration(seconds: timeLimitSeconds)
            : null; // Derive duration here

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        question,
        options,
        correctAnswer,
        locationName,
        latitude,
        longitude,
        photoTheme,
        timeLimitSeconds,
        duration, // Include in props
        startTime,
      ];
}
