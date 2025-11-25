import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/constants/app_strings.dart';

class EventCounter {
  static int countEventsThisWeek(List<MoodleEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));

    return events.where((event) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
      final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

      return deadlineDay.isAfter(today.subtract(const Duration(days: 1))) &&
          deadlineDay.isBefore(weekFromNow);
    }).length;
  }

  static String getSummaryText(int count) {
    if (count == 0) {
      return AppStrings.noDeadlinesThisWeek;
    } else if (count == 1) {
      return AppStrings.oneDeadlineThisWeek;
    } else {
      return AppStrings.multipleDeadlinesThisWeek
          .replaceAll('{count}', count.toString());
    }
  }
}
