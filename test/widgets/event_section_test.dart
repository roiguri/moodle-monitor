import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/widgets/event_section.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he_IL', null);
  });

  testWidgets('EventSection triggers onIgnore when swiped right', (WidgetTester tester) async {
    bool ignored = false;
    MoodleEvent? ignoredEvent;

    final event = MoodleEvent(
      id: 1,
      name: 'Event 1',
      course: 'Course 1',
      courseid: 1,
      timeSort: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventSection(
          title: 'Test Section',
          events: [event],
          onIgnore: (e) {
            ignored = true;
            ignoredEvent = e;
          },
        ),
      ),
    ));

    // Find the dismissible
    final dismissibleFinder = find.byType(Dismissible);
    expect(dismissibleFinder, findsOneWidget);

    // Swipe Right (Start to End)
    await tester.drag(dismissibleFinder, const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    expect(ignored, isTrue);
    expect(ignoredEvent, event);
  });

  testWidgets('EventSection triggers onMarkDone when swiped left', (WidgetTester tester) async {
    bool markedDone = false;
    MoodleEvent? doneEvent;

    final event = MoodleEvent(
      id: 1,
      name: 'Event 1',
      course: 'Course 1',
      courseid: 1,
      timeSort: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventSection(
          title: 'Test Section',
          events: [event],
          onMarkDone: (e) {
            markedDone = true;
            doneEvent = e;
          },
        ),
      ),
    ));

    // Find the dismissible
    final dismissibleFinder = find.byType(Dismissible);
    expect(dismissibleFinder, findsOneWidget);

    // Swipe Left (End to Start)
    await tester.drag(dismissibleFinder, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    expect(markedDone, isTrue);
    expect(doneEvent, event);
  });
}
