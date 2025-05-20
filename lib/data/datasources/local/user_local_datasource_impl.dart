import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; // Import the database helper
import '../../models/user_model.dart'; // Import the UserModel
import 'user_local_datasource.dart'; // Import the abstract data source
import 'dart:convert'; // For JSON encoding/decoding (for badges)

// ========================================================================
// USER LOCAL DATA SOURCE IMPLEMENTATION (SQLite)
// Interacts with the SQLite database to store and retrieve UserModels.
// ========================================================================
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final DatabaseHelper _databaseHelper;

  UserLocalDataSourceImpl(this._databaseHelper);

  // Helper to convert UserModel to a Map for SQLite insertion/update
  Map<String, dynamic> _userModelToMap(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'role': user.role.name, // Store enum as string
      'facultyId': user.facultyId,
      'totalPoints': user.totalPoints,
      'badges': jsonEncode(user.badges), // Store list of badges as JSON string
      // Add other fields matching the table schema
    };
  }

  // Helper to convert a Map from SQLite to UserModel
  UserModel _userModelFromMap(Map<String, dynamic> map) {
    final List<String> badges =
        (jsonDecode(map['badges'] as String) as List<dynamic>).cast<String>();

    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      role: userRoleFromString(
          map['role'] as String), // Convert string back to enum
      facultyId: map['facultyId'] as String?,
      totalPoints: map['totalPoints'] as int?,
      badges: badges,
    );
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final db = await _databaseHelper.database;
    // Use insert with conflictAlgorithm: ConflictAlgorithm.replace
    // This will insert if the ID doesn't exist, or replace the existing row if it does.
    await db.insert(
      DatabaseHelper.userTable,
      _userModelToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('UserModel ${user.id} saved/updated in SQLite');
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.userTable,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      print('UserModel $userId retrieved from SQLite');
      return _userModelFromMap(maps.first);
    } else {
      print('UserModel $userId not found in SQLite');
      return null; // User not found
    }
  }

  @override
  Future<void> clearUser(String userId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.userTable,
      where: 'id = ?',
      whereArgs: [userId],
    );
    print('UserModel $userId cleared from SQLite');
  }

  @override
  Future<void> clearAllUsers() async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseHelper.userTable);
    print('All UserModels cleared from SQLite');
  }
}
