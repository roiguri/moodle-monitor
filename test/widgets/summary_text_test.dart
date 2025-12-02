import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/widgets/summary_text.dart';
import 'package:moodie/constants/app_strings.dart';

void main() {
  testWidgets('SummaryText displays singular text for 1 event this week', (WidgetTester tester) async {
    final now = DateTime.now();
    // Create an event for tomorrow
    final eventTime = now.add(const Duration(days: 1));
    final event = MoodleEvent(
      id: 1,
      name: 'Event 1',
      course: 'Course 1',
      courseid: 1,
      timeSort: eventTime.millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SummaryText(allEvents: [event]),
      ),
    ));

    expect(find.text(AppStrings.oneDeadlineThisWeek), findsOneWidget);
  });

  testWidgets('SummaryText displays plural text for multiple events this week', (WidgetTester tester) async {
    final now = DateTime.now();
    // Create events for tomorrow
    final eventTime = now.add(const Duration(days: 1));
    final event1 = MoodleEvent(
      id: 1,
      name: 'Event 1',
      course: 'Course 1',
      courseid: 1,
      timeSort: eventTime.millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );
    final event2 = MoodleEvent(
      id: 2,
      name: 'Event 2',
      course: 'Course 2',
      courseid: 2,
      timeSort: eventTime.millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SummaryText(allEvents: [event1, event2]),
      ),
    ));

    final expectedText = AppStrings.multipleDeadlinesThisWeek.replaceAll('{count}', '2');
    expect(find.text(expectedText), findsOneWidget);
  });

  testWidgets('SummaryText displays no deadlines text when count is 0', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SummaryText(allEvents: []),
      ),
    ));

    expect(find.text(AppStrings.noDeadlinesThisWeek), findsOneWidget);
  });
}
