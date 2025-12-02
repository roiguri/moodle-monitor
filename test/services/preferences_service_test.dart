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
    test('toggleCourseVisibility correctly toggles visibility and persists', () async {
      final courseId = '101';

      // Initially not hidden
      expect(await preferencesService.isCourseHidden(courseId), false);

      // Toggle to hide
      await preferencesService.toggleCourseVisibility(courseId);
      expect(await preferencesService.isCourseHidden(courseId), true);
      expect(await preferencesService.getHiddenCourses(), contains(courseId));

      // Toggle to show
      await preferencesService.toggleCourseVisibility(courseId);
      expect(await preferencesService.isCourseHidden(courseId), false);
      expect(await preferencesService.getHiddenCourses(), isNot(contains(courseId)));
    });
  });
}
