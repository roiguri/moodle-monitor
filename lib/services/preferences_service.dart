import 'package:shared_preferences/shared_preferences.dart';

/// PreferencesService manages non-sensitive app preferences
/// Uses SharedPreferences for local storage
class PreferencesService {
  static const String _keyHiddenCourses = 'hidden_courses';
  static const String _keyIgnoredEvents = 'ignored_events';
  static const String _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  PreferencesService._(this._prefs);

  /// Initialize the preferences service
  static Future<PreferencesService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  /// Get list of hidden course IDs
  Future<List<String>> getHiddenCourses() async {
    return _prefs.getStringList(_keyHiddenCourses) ?? [];
  }

  /// Save list of hidden course IDs
  Future<bool> setHiddenCourses(List<String> courseIds) async {
    return await _prefs.setStringList(_keyHiddenCourses, courseIds);
  }

  /// Add a course to the hidden list
  Future<bool> hideCourse(String courseId) async {
    final hiddenCourses = await getHiddenCourses();
    if (!hiddenCourses.contains(courseId)) {
      hiddenCourses.add(courseId);
      return await setHiddenCourses(hiddenCourses);
    }
    return true;
  }

  /// Remove a course from the hidden list
  Future<bool> showCourse(String courseId) async {
    final hiddenCourses = await getHiddenCourses();
    if (hiddenCourses.contains(courseId)) {
      hiddenCourses.remove(courseId);
      return await setHiddenCourses(hiddenCourses);
    }
    return true;
  }

  /// Check if a course is hidden
  Future<bool> isCourseHidden(String courseId) async {
    final hiddenCourses = await getHiddenCourses();
    return hiddenCourses.contains(courseId);
  }

  /// Toggle course visibility (hide if visible, show if hidden)
  Future<bool> toggleCourseVisibility(String courseId) async {
    final isHidden = await isCourseHidden(courseId);
    if (isHidden) {
      return await showCourse(courseId);
    } else {
      return await hideCourse(courseId);
    }
  }

  // --- Ignored Events Logic ---

  /// Get list of ignored event IDs
  Future<List<String>> getIgnoredEvents() async {
    return _prefs.getStringList(_keyIgnoredEvents) ?? [];
  }

  /// Add an event to the ignore list
  Future<bool> ignoreEvent(int eventId) async {
    final ignored = await getIgnoredEvents();
    final idStr = eventId.toString();
    if (!ignored.contains(idStr)) {
      ignored.add(idStr);
      return await _prefs.setStringList(_keyIgnoredEvents, ignored);
    }
    return true;
  }

  /// Un-ignore an event (optional, for undo functionality)
  Future<bool> unignoreEvent(int eventId) async {
    final ignored = await getIgnoredEvents();
    final idStr = eventId.toString();
    if (ignored.contains(idStr)) {
      ignored.remove(idStr);
      return await _prefs.setStringList(_keyIgnoredEvents, ignored);
    }
    return true;
  }

  /// Remove ignored IDs that are no longer in the fetched list
  /// [currentEventIds] List of IDs currently fetched from Moodle
  Future<void> cleanupIgnoredEvents(List<String> currentEventIds) async {
    final ignored = await getIgnoredEvents();
    if (ignored.isEmpty) return;

    final currentSet = currentEventIds.toSet();
    final List<String> toKeep = [];

    for (final id in ignored) {
      if (currentSet.contains(id)) {
        toKeep.add(id);
      }
    }

    if (toKeep.length != ignored.length) {
      await _prefs.setStringList(_keyIgnoredEvents, toKeep);
    }
  }

  /// Get theme mode (light, dark, system)
  /// Returns: 'light', 'dark', or 'system'
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Set theme mode
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(_keyThemeMode, mode);
  }

  /// Clear all preferences (useful for testing or reset)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
