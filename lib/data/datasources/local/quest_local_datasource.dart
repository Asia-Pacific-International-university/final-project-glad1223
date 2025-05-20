import '../../models/quest_model.dart';

// ========================================================================
// ABSTRACT QUEST LOCAL DATA SOURCE
// Defines the contract for interacting with local quest data storage (SQLite).
// Useful for caching the active quest or storing past quest history.
// ========================================================================
abstract class QuestLocalDataSource {
  /// Saves a quest model to local storage.
  Future<void> saveQuest(QuestModel quest);

  /// Retrieves a quest model from local storage by ID.
  Future<QuestModel?> getQuest(String questId);

  /// Retrieves the currently active quest from local storage (if cached).
  Future<QuestModel?> getActiveQuest();

  /// Clears a specific quest's data from local storage by ID.
  Future<void> clearQuest(String questId);

  /// Clears all quest data from local storage.
  Future<void> clearAllQuests();
}
