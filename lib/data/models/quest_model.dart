import '../../domain/entities/quest.dart'; // Import the Quest entity
//import 'package:collection/collection.dart';

class QuestModel {
  final String? id;
  final QuestType? type; // Now correctly using the domain's QuestType
  final String? question; // For trivia, polls, puzzles
  final List<String>? options; // For trivia, polls
  final String? correctAnswer; // For trivia, puzzles
  final String? locationName; // For location check-in
  final double? latitude; // For location check-in
  final double? longitude; // For location check-in
  final String? photoTheme; // For photo challenge
  final int? timeLimitSeconds;
  final DateTime? startTime;

  QuestModel({
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

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String?,
      type: _decodeQuestType(json['type']), // Use a custom decoding function
      question: json['question'] as String?,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctAnswer: json['correctAnswer'] as String?,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoTheme: json['photoTheme'] as String?,
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
    );
  }

  Quest toDomain() {
    return Quest(
      id: id,
      type: type, // Now these types should match
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      photoTheme: photoTheme,
      timeLimitSeconds: timeLimitSeconds,
      startTime: startTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _encodeQuestType(type), // Use a custom encoding function
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'photoTheme': photoTheme,
      'timeLimitSeconds': timeLimitSeconds,
      'startTime': startTime?.toIso8601String(),
    };
  }
}

// Custom function to decode the QuestType from JSON
QuestType? _decodeQuestType(dynamic source) {
  if (source == null) {
    return null;
  }
  switch (source as String) {
    case 'trivia':
      return QuestType.trivia;
    case 'poll':
      return QuestType.poll;
    case 'locationCheckIn':
      return QuestType.locationCheckIn;
    case 'photoChallenge':
      return QuestType.photoChallenge;
    case 'miniPuzzle':
      return QuestType.miniPuzzle;
    default:
      return null; // Or throw an error if an unknown value is encountered
  }
}

// Custom function to encode the QuestType to JSON
String? _encodeQuestType(QuestType? type) {
  switch (type) {
    case QuestType.trivia:
      return 'trivia';
    case QuestType.poll:
      return 'poll';
    case QuestType.locationCheckIn:
      return 'locationCheckIn';
    case QuestType.photoChallenge:
      return 'photoChallenge';
    case QuestType.miniPuzzle:
      return 'miniPuzzle';
    default:
      return null;
  }
}

extension CollectionExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
