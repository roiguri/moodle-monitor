import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/constants/app_strings.dart';

void main() {
  group('EventDateUtils', () {
    test('getPriority returns correct priority', () {
      final now = DateTime.now();

      // High: Today
      expect(EventDateUtils.getPriority(now), EventPriority.high);

      // High: Past
      expect(EventDateUtils.getPriority(now.subtract(const Duration(days: 1))), EventPriority.high);

      // Medium: Tomorrow
      expect(EventDateUtils.getPriority(now.add(const Duration(days: 1))), EventPriority.medium);

      // Low: Future (2 days later)
      expect(EventDateUtils.getPriority(now.add(const Duration(days: 2))), EventPriority.low);
    });

    test('groupEventsByDate buckets events correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      MoodleEvent createEvent(int id, DateTime date) {
        return MoodleEvent(
          id: id,
          name: 'Event $id',
          course: 'Course',
          courseid: 1,
          timeSort: date.millisecondsSinceEpoch ~/ 1000,
          courseViewUrl: '',
          url: '',
        );
      }

      final todayEvent = createEvent(1, today.add(const Duration(hours: 1)));
      final tomorrowEvent = createEvent(2, today.add(const Duration(days: 1, hours: 1)));
      final nextWeekEvent = createEvent(3, today.add(const Duration(days: 3)));
      final nextMonthEvent = createEvent(4, today.add(const Duration(days: 15)));
      final laterEvent = createEvent(5, today.add(const Duration(days: 40)));

      final events = [todayEvent, tomorrowEvent, nextWeekEvent, nextMonthEvent, laterEvent];
      final grouped = EventDateUtils.groupEventsByDate(events);

      expect(grouped[AppStrings.today], contains(todayEvent));
      expect(grouped[AppStrings.tomorrow], contains(tomorrowEvent));
      expect(grouped[AppStrings.next7Days], contains(nextWeekEvent));
      expect(grouped[AppStrings.next30Days], contains(nextMonthEvent));
      expect(grouped[AppStrings.later], contains(laterEvent));
    });
  });
}
