import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodie/services/preferences_service.dart';

void main() {
  late PreferencesService preferencesService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferencesService = await PreferencesService.getInstance();
  });

  group('PreferencesService', () {
    // --- Hidden Courses ---
    test('Hidden courses logic works correctly', () async {
      final courseId = '101';

      // Initially empty
      expect(await preferencesService.getHiddenCourses(), isEmpty);
      expect(await preferencesService.isCourseHidden(courseId), false);

      // Hide course
      await preferencesService.hideCourse(courseId);
      expect(await preferencesService.isCourseHidden(courseId), true);
      expect(await preferencesService.getHiddenCourses(), contains(courseId));

      // Hide same course again (should not duplicate)
      await preferencesService.hideCourse(courseId);
      expect((await preferencesService.getHiddenCourses()).length, 1);

      // Show course
      await preferencesService.showCourse(courseId);
      expect(await preferencesService.isCourseHidden(courseId), false);
      expect(await preferencesService.getHiddenCourses(), isNot(contains(courseId)));

      // Show course that is not hidden (should do nothing)
      await preferencesService.showCourse(courseId);
      expect(await preferencesService.getHiddenCourses(), isEmpty);

      // Toggle visibility
      await preferencesService.toggleCourseVisibility(courseId);
      expect(await preferencesService.isCourseHidden(courseId), true);
      await preferencesService.toggleCourseVisibility(courseId);
      expect(await preferencesService.isCourseHidden(courseId), false);
      
      // Set multiple hidden courses
      await preferencesService.setHiddenCourses(['101', '102']);
      expect((await preferencesService.getHiddenCourses()).length, 2);
    });

    // --- Ignored Events ---
    test('Ignored events logic works correctly', () async {
      final eventId = 123;

      // Initially empty
      expect(await preferencesService.getIgnoredEvents(), isEmpty);

      // Ignore event
      await preferencesService.ignoreEvent(eventId);
      expect(await preferencesService.getIgnoredEvents(), contains(eventId.toString()));

      // Ignore same event again
      await preferencesService.ignoreEvent(eventId);
      expect((await preferencesService.getIgnoredEvents()).length, 1);

      // Unignore event
      await preferencesService.unignoreEvent(eventId);
      expect(await preferencesService.getIgnoredEvents(), isEmpty);
      
      // Unignore event that is not ignored
      await preferencesService.unignoreEvent(eventId);
      expect(await preferencesService.getIgnoredEvents(), isEmpty);
    });

    test('cleanupIgnoredEvents removes obsolete IDs', () async {
      await preferencesService.ignoreEvent(1);
      await preferencesService.ignoreEvent(2);
      await preferencesService.ignoreEvent(3);

      // Current events only contain 1 and 3, so 2 should be removed
      await preferencesService.cleanupIgnoredEvents(['1', '3']);

      final ignored = await preferencesService.getIgnoredEvents();
      expect(ignored, contains('1'));
      expect(ignored, contains('3'));
      expect(ignored, isNot(contains('2')));
    });

    // --- Theme Mode ---
    test('Theme mode preferences work correctly', () async {
      // Default
      expect(preferencesService.getThemeMode(), 'system');

      // Set to dark
      await preferencesService.setThemeMode('dark');
      expect(preferencesService.getThemeMode(), 'dark');

      // Set to light
      await preferencesService.setThemeMode('light');
      expect(preferencesService.getThemeMode(), 'light');
    });

    // --- Notification Settings ---
    test('Notification preferences work correctly', () async {
      // Defaults
      expect(preferencesService.getNotifyNewTasks(), false); // Based on code reading, default might be false or null?? Code says: _prefs.getBool(_keyNotifyNewTasks) ?? false;
      expect(preferencesService.getNotifyDeadlines(), false);

      // Set New Tasks
      await preferencesService.setNotifyNewTasks(true);
      expect(preferencesService.getNotifyNewTasks(), true);

      // Set Deadlines
      await preferencesService.setNotifyDeadlines(true);
      expect(preferencesService.getNotifyDeadlines(), true);
    });

    test('Deadline alerts preferences work correctly', () async {
      // Default
      expect(preferencesService.getDeadlineAlerts(), [60]);

      // Set alerts
      await preferencesService.setDeadlineAlerts([30, 120]);
      final alerts = preferencesService.getDeadlineAlerts();
      expect(alerts, containsAll([30, 120]));
      expect(alerts.length, 2);
    });

    // --- Onboarding ---
    test('Onboarding status works correctly', () async {
      // Default
      expect(preferencesService.getIsOnboarded(), false);

      // Set
      await preferencesService.setIsOnboarded(true);
      expect(preferencesService.getIsOnboarded(), true);
    });

    // --- First Fetch ---
    test('First fetch status works correctly', () async {
      // Default
      expect(preferencesService.getIsFirstFetchCompleted(), false);

      // Set
      await preferencesService.setIsFirstFetchCompleted(true);
      expect(preferencesService.getIsFirstFetchCompleted(), true);
    });

    // --- Clear All ---
    test('clearAll clears all preferences', () async {
      await preferencesService.setThemeMode('dark');
      await preferencesService.setIsOnboarded(true);
      
      await preferencesService.clearAll();
      
      expect(preferencesService.getThemeMode(), 'system');
      expect(preferencesService.getIsOnboarded(), false);
    });
  });
}
