import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyKnownTaskIds = 'known_task_ids';

  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Retrieves the list of task IDs that have already been notified/seen.
  Future<List<String>> getKnownTaskIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyKnownTaskIds) ?? [];
  }

  /// Saves the list of task IDs.
  Future<void> saveTaskIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyKnownTaskIds, ids);
  }

  /// Adds new IDs to the existing list and saves.
  Future<void> addKnownTaskIds(List<String> newIds) async {
    final currentIds = await getKnownTaskIds();
    final uniqueIds = {...currentIds, ...newIds}.toList();
    await saveTaskIds(uniqueIds);
  }
  
  /// Clears the cache (useful for testing or resetting)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyKnownTaskIds);
  }
}
