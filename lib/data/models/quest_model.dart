import '../../domain/entities/quest.dart';
import 'package:collection/collection.dart';

enum QuestType { trivia, poll, locationCheckIn, photoChallenge, miniPuzzle }

class QuestModel {
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
      type: $enumDecodeNullable(_$QuestTypeEnumMap, json['type']),
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
      type: type,
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
      'type': _$QuestTypeEnumMap[type],
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

const _$QuestTypeEnumMap = <QuestType, dynamic>{
  QuestType.trivia: 'trivia',
  QuestType.poll: 'poll',
  QuestType.locationCheckIn: 'locationCheckIn',
  QuestType.photoChallenge: 'photoChallenge',
  QuestType.miniPuzzle: 'miniPuzzle',
};

T? $enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return enumValues.entries.singleWhereOrNull((e) => e.value == source)?.key;
}

T $enumDecode<T>(Map<T, dynamic> enumValues, dynamic source,
    {T? unknownValue}) {
  if (source == null) {
    throw ArgumentError('A required value must be provided but was null.');
  }
  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '`${enumValues.values.join(', ')}`',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
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
