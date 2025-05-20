import '../../models/user_model.dart';

// ========================================================================
// ABSTRACT USER LOCAL DATA SOURCE
// Defines the contract for interacting with local user data storage (SQLite).
// ========================================================================
abstract class UserLocalDataSource {
  /// Saves a user model to local storage.
  Future<void> saveUser(UserModel user);

  /// Retrieves a user model from local storage by ID.
  Future<UserModel?> getUser(String userId);

  /// Clears a specific user's data from local storage by ID.
  Future<void> clearUser(String userId);

  /// Clears all user data from local storage.
  Future<void> clearAllUsers();
}
