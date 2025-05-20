import '../../models/faculty_model.dart'; // Import the FacultyModel

// ========================================================================
// ABSTRACT FACULTY LOCAL DATA SOURCE
// Defines the contract for interacting with local faculty data storage (SQLite).
// Useful for caching the faculty list for the leaderboard or selection.
// ========================================================================
abstract class FacultyLocalDataSource {
  /// Saves a list of faculty models to local storage.
  /// This usually replaces the existing list.
  Future<void> saveFaculties(List<FacultyModel> faculties);

  /// Retrieves the list of faculty models from local storage.
  Future<List<FacultyModel>> getFaculties();

  /// Clears all faculty data from local storage.
  Future<void> clearAllFaculties();

  // Optional: Add methods to get a single faculty by ID if needed
  // Future<FacultyModel?> getFacultyById(String facultyId);
}
