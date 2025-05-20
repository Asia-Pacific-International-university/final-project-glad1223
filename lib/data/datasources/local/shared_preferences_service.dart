import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ========================================================================
// SHARED PREFERENCES SERVICE
// Handles simple key-value storage using SharedPreferences.
// Suitable for user preferences, settings, flags, etc.
// ========================================================================
class SharedPreferencesService {
  // Use a Future to get the SharedPreferences instance once
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Private constructor
  SharedPreferencesService._privateConstructor();

  // Singleton instance
  static final SharedPreferencesService _instance =
      SharedPreferencesService._privateConstructor();

  // Factory constructor to return the singleton instance
  factory SharedPreferencesService() {
    return _instance;
  }

  // --- Methods for storing and retrieving various data types ---

  Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(key);
  }

  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(key);
  }

  // --- Other utility methods ---

  Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  // Optional: Initialize method if you need to await instance before first use
  // Future<void> init() async {
  //   _prefs = SharedPreferences.getInstance();
  //   await _prefs; // Await the instance once
  // }
}
