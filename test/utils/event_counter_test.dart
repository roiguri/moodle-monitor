import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/utils/event_counter.dart';
import 'package:moodie/models/moodle_event.dart';

void main() {
  group('EventCounter', () {
    test('countEventsThisWeek counts events within the next 7 days', () {
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

      // Inside the week
      final eventToday = createEvent(1, today.add(const Duration(hours: 1)));
      final eventIn3Days = createEvent(2, today.add(const Duration(days: 3)));
      final eventIn6Days = createEvent(3, today.add(const Duration(days: 6)));

      // Outside the week
      final eventYesterday = createEvent(4, today.subtract(const Duration(days: 1)));
      final eventIn8Days = createEvent(5, today.add(const Duration(days: 8)));

      final events = [
          eventToday,
          eventIn3Days,
          eventIn6Days,
          eventYesterday,
          eventIn8Days
      ];

      final count = EventCounter.countEventsThisWeek(events);

      expect(count, 3);
    });
  });
}
