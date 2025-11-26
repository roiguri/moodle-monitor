import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/constants/app_strings.dart';

enum EventPriority { high, medium, low }

class EventDateUtils {
  static EventPriority getPriority(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

    if (deadlineDay.isAtSameMomentAs(today)) {
      return EventPriority.high; // Today = Red
    } else if (deadlineDay.isAtSameMomentAs(tomorrow)) {
      return EventPriority.medium; // Tomorrow = Orange
    } else {
      return EventPriority.low; // Future = Green
    }
  }

  static Map<String, List<MoodleEvent>> groupEventsByDate(List<MoodleEvent> events) {
    final Map<String, List<MoodleEvent>> groupedEvents = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final event in events) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
      final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
      final daysUntil = deadlineDay.difference(today).inDays;

      String dayKey;
      if (daysUntil == 0) {
        dayKey = AppStrings.today;
      } else if (daysUntil == 1) {
        dayKey = AppStrings.tomorrow;
      } else if (daysUntil <= 7) {
        dayKey = AppStrings.next7Days;
      } else if (daysUntil <= 30) {
        dayKey = AppStrings.next30Days;
      } else {
        dayKey = AppStrings.later;
      }

      if (groupedEvents.containsKey(dayKey)) {
        groupedEvents[dayKey]!.add(event);
      } else {
        groupedEvents[dayKey] = [event];
      }
    }
    return groupedEvents;
  }

  static List<String> getSortedDayKeys(Map<String, List<MoodleEvent>> grouped) {
    final dayKeys = grouped.keys.toList();

    // Define order
    final order = [
      AppStrings.today,
      AppStrings.tomorrow,
      AppStrings.next7Days,
      AppStrings.next30Days,
      AppStrings.later,
    ];

    // Sort according to the order
    dayKeys.sort((a, b) {
      int indexA = order.indexOf(a);
      int indexB = order.indexOf(b);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      return indexA.compareTo(indexB);
    });

    return dayKeys;
  }
}
