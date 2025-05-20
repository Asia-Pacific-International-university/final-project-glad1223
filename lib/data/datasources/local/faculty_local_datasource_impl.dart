import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; // Import the database helper
import '../../models/faculty_model.dart'; // Import the FacultyModel
import 'faculty_local_datasource.dart'; // Import the abstract data source
import 'dart:convert'; // For JSON encoding/decoding (for badges)

// ========================================================================
// FACULTY LOCAL DATA SOURCE IMPLEMENTATION (SQLite)
// Interacts with the SQLite database to store and retrieve FacultyModels.
// ========================================================================
class FacultyLocalDataSourceImpl implements FacultyLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FacultyLocalDataSourceImpl(this._databaseHelper);

  // Helper to convert FacultyModel to a Map for SQLite insertion/update
  Map<String, dynamic> _facultyModelToMap(FacultyModel faculty) {
    return {
      'id': faculty.id,
      'name': faculty.name,
      'points': faculty.points,
      'totalCorrectAnswers': faculty.totalCorrectAnswers,
      'totalQuestionsAttempted': faculty.totalQuestionsAttempted,
      'totalParticipationEvents': faculty.totalParticipationEvents,
      'fastestCompletionTimeMs': faculty.fastestCompletionTimeMs,
      'lastActivity': faculty
          .lastActivity?.millisecondsSinceEpoch, // Store DateTime as timestamp
      'badges':
          jsonEncode(faculty.badges), // Store list of badges as JSON string
      // Add other fields matching the table schema
    };
  }

  // Helper to convert a Map from SQLite to FacultyModel
  FacultyModel _facultyModelFromMap(Map<String, dynamic> map) {
    final List<String> badges =
        (jsonDecode(map['badges'] as String) as List<dynamic>).cast<String>();

    return FacultyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      points: map['points'] as int,
      totalCorrectAnswers: map['totalCorrectAnswers'] as int,
      totalQuestionsAttempted: map['totalQuestionsAttempted'] as int,
      totalParticipationEvents: map['totalParticipationEvents'] as int,
      fastestCompletionTimeMs: map['fastestCompletionTimeMs'] as int?,
      lastActivity: map['lastActivity'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActivity'] as int)
          : null,
      badges: badges,
    );
  }

  @override
  Future<void> saveFaculties(List<FacultyModel> faculties) async {
    final db = await _databaseHelper.database;
    // Clear existing data before saving the new list
    await clearAllFaculties();

    // Insert all faculties
    final batch = db.batch();
    for (final faculty in faculties) {
      batch.insert(
        DatabaseHelper.facultyTable, // Use the correct table name
        _facultyModelToMap(faculty),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
    print('${faculties.length} FacultyModels saved/updated in SQLite');
  }

  @override
  Future<List<FacultyModel>> getFaculties() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.facultyTable, // Use the correct table name
      orderBy: 'points DESC', // Order by points for leaderboard cache
    );

    if (maps.isNotEmpty) {
      print('${maps.length} FacultyModels retrieved from SQLite');
      return maps.map((map) => _facultyModelFromMap(map)).toList();
    } else {
      print('No FacultyModels found in SQLite');
      return []; // Return empty list if no data
    }
  }

  @override
  Future<void> clearAllFaculties() async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.facultyTable); // Use the correct table name
    print('All FacultyModels cleared from SQLite');
  }

  // Optional: Implementation for getting a single faculty by ID
  // @override
  // Future<FacultyModel?> getFacultyById(String facultyId) async {
  //   final db = await _databaseHelper.database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     DatabaseHelper.facultyTable,
  //     where: 'id = ?',
  //     whereArgs: [facultyId],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     return _facultyModelFromMap(maps.first);
  //   } else {
  //     return null;
  //   }
  // }
}
