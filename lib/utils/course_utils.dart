import 'package:moodle_monitor/models/moodle_event.dart';

class CourseUtils {
  static Map<String, List<MoodleEvent>> groupEventsByCourse(List<MoodleEvent> events) {
    final Map<String, List<MoodleEvent>> groupedEvents = {};
    for (final event in events) {
      if (groupedEvents.containsKey(event.course)) {
        groupedEvents[event.course]!.add(event);
      } else {
        groupedEvents[event.course] = [event];
      }
    }
    return groupedEvents;
  }

  static List<String> getSortedCourseKeys(Map<String, List<MoodleEvent>> groupedEvents) {
    final keys = groupedEvents.keys.toList();
    keys.sort();
    return keys;
  }
}
