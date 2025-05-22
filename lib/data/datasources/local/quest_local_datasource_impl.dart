import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart'; // Import the logger package
import 'database_helper.dart'; // Import the database helper
import '../../models/quest_model.dart'; // Import the QuestModel
import 'quest_local_datasource.dart'; // Import the abstract data source
import 'dart:convert'; // For JSON encoding/decoding (for options)

// ========================================================================
// QUEST LOCAL DATA SOURCE IMPLEMENTATION (SQLite)
// Interacts with the SQLite database to store and retrieve QuestModels.
// ========================================================================
class QuestLocalDataSourceImpl implements QuestLocalDataSource {
  final DatabaseHelper _databaseHelper;
  // Initialize a logger instance for this class
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No method calls to be displayed
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print emojis
      printTime: false, // Should each log print a timestamp
    ),
  );

  QuestLocalDataSourceImpl(this._databaseHelper);

  // Helper to convert QuestModel to a Map for SQLite insertion/update
  Map<String, dynamic> _questModelToMap(QuestModel quest) {
    return {
      'id': quest.id,
      'type': quest.type?.toString().split('.').last, // Store enum as string
      'question': quest.question,
      'options':
          jsonEncode(quest.options), // Store list of options as JSON string
      'correctAnswer': quest.correctAnswer,
      'locationName': quest.locationName,
      'latitude': quest.latitude,
      'longitude': quest.longitude,
      'photoTheme': quest.photoTheme,
      'timeLimitSeconds': quest.timeLimitSeconds,
      'startTime': quest
          .startTime?.millisecondsSinceEpoch, // Store DateTime as timestamp
      // Add other fields matching the table schema
    };
  }

  // Helper to convert a Map from SQLite to QuestModel
  QuestModel _questModelFromMap(Map<String, dynamic> map) {
    final List<String>? options = map['options'] != null
        ? (jsonDecode(map['options'] as String) as List<dynamic>).cast<String>()
        : null;

    return QuestModel(
      id: map['id'] as String?,
      type: _decodeQuestType(
          map['type'] as String?), // Use helper to decode enum string
      question: map['question'] as String?,
      options: options,
      correctAnswer: map['correctAnswer'] as String?,
      locationName: map['locationName'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      photoTheme: map['photoTheme'] as String?,
      timeLimitSeconds: map['timeLimitSeconds'] as int?,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int)
          : null,
    );
  }

  // Helper to decode QuestType string back to enum
  QuestType? _decodeQuestType(String? typeString) {
    if (typeString == null) return null;
    try {
      return QuestType.values
          .firstWhere((e) => e.toString().split('.').last == typeString);
    } catch (e) {
      // Use logger.w for warnings (unknown type string)
      _logger.w('Unknown quest type string: $typeString', e);
      return null; // Handle unknown types
    }
  }

  @override
  Future<void> saveQuest(QuestModel quest) async {
    if (quest.id == null) {
      // Use logger.e for errors (cannot save null ID)
      _logger.e('Cannot save quest with null ID to SQLite');
      return; // Cannot save quest without an ID
    }
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.questTable,
      _questModelToMap(quest),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Use logger.i for informational messages
    _logger.i('QuestModel ${quest.id} saved/updated in SQLite');
  }

  @override
  Future<QuestModel?> getQuest(String questId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.questTable,
      where: 'id = ?',
      whereArgs: [questId],
    );

    if (maps.isNotEmpty) {
      _logger.i('QuestModel $questId retrieved from SQLite');
      return _questModelFromMap(maps.first);
    } else {
      _logger.i('QuestModel $questId not found in SQLite');
      return null; // Quest not found
    }
  }

  @override
  Future<QuestModel?> getActiveQuest() async {
    final db = await _databaseHelper.database;
    // TODO: Implement logic to determine the "active" quest from local storage.
    // This might involve querying for a quest that hasn't expired based on startTime + timeLimitSeconds,
    // or checking a flag in the table, or simply getting the most recently saved one.
    // For a simple cache of *the* active quest, you might just store one row or query the latest.
    // Example: Get the most recently saved quest (simplistic active cache)
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.questTable,
      orderBy: 'startTime DESC', // Assuming startTime exists and is reliable
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final quest = _questModelFromMap(maps.first);
      // Optional: Check if the cached quest is still "active" based on its timer
      if (quest.startTime != null && quest.timeLimitSeconds != null) {
        final expirationTime =
            quest.startTime!.add(Duration(seconds: quest.timeLimitSeconds!));
        if (DateTime.now().isBefore(expirationTime)) {
          _logger.i('Active QuestModel retrieved from SQLite cache');
          return quest;
        } else {
          _logger.w('Cached active QuestModel has expired. Clearing it.');
          // Optionally clear expired active quest from cache
          if (quest.id != null) {
            clearQuest(quest.id!);
          }
          return null;
        }
      } else {
        // If quest data is incomplete for timer check, return it anyway or null based on strategy
        _logger.i(
            'Active QuestModel retrieved from SQLite cache (no timer info for expiration check)');
        return quest; // Or return null if timer info is mandatory for active
      }
    } else {
      _logger.i('No active QuestModel found in SQLite cache');
      return null;
    }
  }

  @override
  Future<void> clearQuest(String questId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.questTable,
      where: 'id = ?',
      whereArgs: [questId],
    );
    _logger.i('QuestModel $questId cleared from SQLite');
  }

  @override
  Future<void> clearAllQuests() async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.questTable);
    _logger.i('All QuestModels cleared from SQLite');
  }
}
