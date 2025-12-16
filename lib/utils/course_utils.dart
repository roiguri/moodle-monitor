import 'package:moodie/models/app_event.dart';

class CourseUtils {
  static Map<String, List<AppEvent>> groupEventsByCourse(List<AppEvent> events) {
    final Map<String, List<AppEvent>> groupedEvents = {};
    for (final event in events) {
      final courseName = event.courseName.isNotEmpty ? event.courseName : 'Personal';
      if (groupedEvents.containsKey(courseName)) {
        groupedEvents[courseName]!.add(event);
      } else {
        groupedEvents[courseName] = [event];
      }
    }
    return groupedEvents;
  }

  static List<String> getSortedCourseKeys(Map<String, List<AppEvent>> groupedEvents) {
    final keys = groupedEvents.keys.toList();
    keys.sort();
    return keys;
  }
}
