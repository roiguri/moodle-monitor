import 'package:intl/intl.dart';
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
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(const Duration(days: 7));
    final endOfNextWeek = today.add(const Duration(days: 14));
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    for (final event in events) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
      final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

      String dayKey;
      if (deadlineDay.isAtSameMomentAs(today)) {
        dayKey = AppStrings.today;
      } else if (deadlineDay.isAtSameMomentAs(tomorrow)) {
        dayKey = AppStrings.tomorrow;
      } else if (deadlineDay.isBefore(endOfWeek)) {
        dayKey = AppStrings.thisWeek;
      } else if (deadlineDay.isBefore(endOfNextWeek)) {
        dayKey = AppStrings.nextWeek;
      } else if (deadlineDay.isBefore(endOfMonth) || deadlineDay.isAtSameMomentAs(endOfMonth)) {
        dayKey = AppStrings.thisMonth;
      } else {
        dayKey = AppStrings.overMonth;
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
      AppStrings.thisWeek,
      AppStrings.nextWeek,
      AppStrings.thisMonth,
      AppStrings.overMonth,
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
