import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// ========================================================================
// DATABASE HELPER
// Manages the SQLite database creation, opening, and versioning.
// Provides a single instance of the database.
// ========================================================================
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Database name and version
  static const String _databaseName = 'campus_pulse_challenge.db';
  static const int _databaseVersion = 1; // Keep version 1 for initial tables

  // Table names
  static const String userTable = 'users';
  static const String questTable = 'quests';
  static const String facultyTable = 'faculties'; // Added faculty table name
  // Add other table names here as needed

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // If database is null, initialize it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Open the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Keep onUpgrade for future schema changes
    );
  }

  // Create the database tables
  Future _onCreate(Database db, int version) async {
    // Create the 'users' table
    await db.execute('''
      CREATE TABLE $userTable (
        id TEXT PRIMARY KEY,
        email TEXT,
        username TEXT,
        role TEXT,
        facultyId TEXT,
        totalPoints INTEGER,
        badges TEXT -- Store badges as a comma-separated string or JSON
      )
    ''');

    // Create the 'quests' table (for caching active quest or storing past quests)
    await db.execute('''
      CREATE TABLE $questTable (
        id TEXT PRIMARY KEY,
        type TEXT,
        question TEXT,
        options TEXT, -- Store options as JSON string
        correctAnswer TEXT,
        locationName TEXT,
        latitude REAL,
        longitude REAL,
        photoTheme TEXT,
        timeLimitSeconds INTEGER,
        startTime INTEGER -- Store DateTime as Unix timestamp (integer)
        -- Add other quest-specific fields here
      )
    ''');

    // Create the 'faculties' table (for caching leaderboard data)
    await db.execute('''
      CREATE TABLE $facultyTable (
        id TEXT PRIMARY KEY,
        name TEXT,
        points INTEGER,
        totalCorrectAnswers INTEGER,
        totalQuestionsAttempted INTEGER,
        totalParticipationEvents INTEGER,
        fastestCompletionTimeMs INTEGER, -- Nullable
        lastActivity INTEGER, -- Nullable, stored as timestamp
        badges TEXT -- Store badges as JSON string
      )
    ''');

    // TODO: Add CREATE TABLE statements for any other tables
  }

  // Upgrade the database schema (if version changes)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implement database migration logic here if you change the schema version
    // Example: Add a new column in version 2
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $userTable ADD COLUMN newColumn TEXT;');
    // }
    print('Database upgraded from version $oldVersion to $newVersion');
  }

  // Close the database (optional, usually managed by the system)
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null; // Set database instance to null after closing
  }
}
