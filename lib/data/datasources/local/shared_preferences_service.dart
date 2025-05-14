import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/core/error/failures.dart';
import 'dart:convert';

class SharedPreferencesService {
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  Future<String?> getString(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _prefsFuture;
    return prefs.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _prefsFuture;
    return prefs.setInt(key, value);
  }

  Future<bool> remove(String key) async {
    final prefs = await _prefsFuture;
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final prefs = await _prefsFuture;
    return prefs.clear();
  }

  // Example for storing and retrieving a list of strings (e.g., badges)
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _prefsFuture;
    return prefs.setStringList(key, value);
  }

  // Example for storing and retrieving a complex object as JSON
  Future<Map<String, dynamic>?> getObject(String key) async {
    final prefs = await _prefsFuture;
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>?;
      } catch (e) {
        print('Error decoding JSON for key: $key - $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final prefs = await _prefsFuture;
    final jsonString = jsonEncode(value);
    return prefs.setString(key, jsonString);
  }
}
