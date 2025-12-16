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

  // --- Notification Settings ---
  static const String _keyNotifyNewTasks = 'notify_new_tasks';
  static const String _keyNotifyDeadlines = 'notify_deadlines';

  /// Get new task notification preference (default: true)
  bool getNotifyNewTasks() {
    return _prefs.getBool(_keyNotifyNewTasks) ?? false;
  }

  /// Set new task notification preference
  Future<bool> setNotifyNewTasks(bool enabled) async {
    return await _prefs.setBool(_keyNotifyNewTasks, enabled);
  }

  /// Get deadline notification preference (default: true)
  bool getNotifyDeadlines() {
    return _prefs.getBool(_keyNotifyDeadlines) ?? false;
  }

  /// Set deadline notification preference
  Future<bool> setNotifyDeadlines(bool enabled) async {
    return await _prefs.setBool(_keyNotifyDeadlines, enabled);
  }

  static const String _keyDeadlineAlerts = 'deadline_alerts';

  /// Get list of deadline alert offsets in minutes (default: [60] -> 1 hour)
  List<int> getDeadlineAlerts() {
    final List<String>? stored = _prefs.getStringList(_keyDeadlineAlerts);
    if (stored == null) {
      return [60]; // Default: 1 hour
    }
    return stored.map((e) => int.tryParse(e) ?? 60).toList();
  }

  /// Set list of deadline alert offsets in minutes
  Future<bool> setDeadlineAlerts(List<int> alerts) async {
    final List<String> stored = alerts.toSet().map((e) => e.toString()).toList();
    return await _prefs.setStringList(_keyDeadlineAlerts, stored);
  }

  /// Clear all preferences (useful for testing or reset)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // --- Onboarding ---
  static const String _keyIsOnboarded = 'is_onboarded';

  /// Check if user has completed onboarding
  bool getIsOnboarded() {
    return _prefs.getBool(_keyIsOnboarded) ?? false;
  }

  /// Set onboarding completion status
  Future<bool> setIsOnboarded(bool value) async {
    return await _prefs.setBool(_keyIsOnboarded, value);
  }

  // --- First Fetch Flag ---
  static const String _keyIsFirstFetchCompleted = 'is_first_fetch_completed';

  /// Check if the first data fetch has been completed
  bool getIsFirstFetchCompleted() {
    return _prefs.getBool(_keyIsFirstFetchCompleted) ?? false;
  }

  /// Set first fetch completion status
  Future<bool> setIsFirstFetchCompleted(bool value) async {
    return await _prefs.setBool(_keyIsFirstFetchCompleted, value);
  }

  /// Reloads the preferences from disk.
  /// Useful when preferences might have been changed by another process (e.g., widget).
  Future<void> reload() async {
    await _prefs.reload();
  }
}
