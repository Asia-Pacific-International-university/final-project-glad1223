// domain/entities/quest.dart
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
  final String? title;
  final String? description;
  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? photoTheme;
  final int? timeLimitSeconds;
  final DateTime? startTime;

  Quest({
    this.id,
    this.type,
    this.title,
    this.description,
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
        startTime,
      ];
}
