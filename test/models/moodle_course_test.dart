import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/moodle_course.dart';

void main() {
  group('MoodleCourse', () {
    test('fromJson correctly constructs viewUrl with moodleUrl', () {
      final json = {
        'id': 101,
        'fullname': 'Introduction to Computer Science',
        'shortname': 'CS101',
      };
      final moodleUrl = 'https://moodle.university.edu';

      final course = MoodleCourse.fromJson(json, moodleUrl: moodleUrl);

      expect(course.id, 101);
      expect(course.fullName, 'Introduction to Computer Science');
      expect(course.shortName, 'CS101');
      expect(course.viewUrl, 'https://moodle.university.edu/course/view.php?id=101');
    });

    test('fromJson handles missing moodleUrl', () {
      final json = {
        'id': 101,
        'fullname': 'Introduction to Computer Science',
        'shortname': 'CS101',
      };

      final course = MoodleCourse.fromJson(json);

      expect(course.viewUrl, null);
    });
  });
}
