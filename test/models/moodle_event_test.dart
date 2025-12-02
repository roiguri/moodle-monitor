import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/moodle_event.dart';

void main() {
  group('MoodleEvent', () {
    test('fromJson correctly parses standard API responses', () {
      final json = {
        'id': 123,
        'activityname': 'Assignment 1',
        'course': {
          'id': 456,
          'shortname': 'CS101',
          'viewurl': 'https://moodle.example.com/course/view.php?id=456',
          'coursemoduleid': 789
        },
        'timesort': 1625097600,
        'url': 'https://moodle.example.com/mod/assign/view.php?id=789'
      };

      final event = MoodleEvent.fromJson(json);

      expect(event.id, 123);
      expect(event.name, 'Assignment 1');
      expect(event.course, 'CS101');
      expect(event.courseid, 456);
      expect(event.timeSort, 1625097600);
      expect(event.courseViewUrl, 'https://moodle.example.com/course/view.php?id=456');
      expect(event.url, 'https://moodle.example.com/mod/assign/view.php?id=789');
      expect(event.cmid, 789);
    });

    test('fromJson extracts cmid from url when missing in course object', () {
      final json = {
        'id': 123,
        'activityname': 'Assignment 1',
        'course': {
          'id': 456,
          'shortname': 'CS101',
          'viewurl': 'https://moodle.example.com/course/view.php?id=456',
          // coursemoduleid is missing
        },
        'timesort': 1625097600,
        'url': 'https://moodle.example.com/mod/assign/view.php?id=789'
      };

      final event = MoodleEvent.fromJson(json);

      expect(event.cmid, 789);
    });

    test('fromJson handles cmid extraction failure gracefully', () {
      final json = {
        'id': 123,
        'activityname': 'Assignment 1',
        'course': {
          'id': 456,
          'shortname': 'CS101',
          'viewurl': 'https://moodle.example.com/course/view.php?id=456',
        },
        'timesort': 1625097600,
        'url': 'https://moodle.example.com/mod/assign/view.php' // No ID param
      };

      final event = MoodleEvent.fromJson(json);

      expect(event.cmid, null);
    });
  });
}
