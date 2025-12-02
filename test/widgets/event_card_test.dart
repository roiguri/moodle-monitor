import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moodie/constants/app_colors.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:moodie/widgets/event_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he_IL', null);
  });

  // Create a fixed time event
  // 2023-11-15 14:30:00 UTC
  // We need to check what time zone the test runs in, or what Intl uses.
  // Intl usually defaults to system locale/timezone.
  // We'll set up the date such that it produces predictable output.
  // Hebrew date format for MMd: "15 בנוב׳"
  final deadline = DateTime(2023, 11, 15, 14, 30);
  final timeSort = deadline.millisecondsSinceEpoch ~/ 1000;

  final event = MoodleEvent(
    id: 1,
    name: 'Test Assignment',
    course: 'Test Course',
    courseid: 101,
    timeSort: timeSort,
    courseViewUrl: 'http://example.com/course',
    url: 'http://example.com/assign',
  );

  testWidgets('EventCard renders correct colors for High priority', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventCard(
          event: event,
          priority: EventPriority.high,
        ),
      ),
    ));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, AppColors.highPriorityBg);
    final border = decoration.border as Border;
    expect(border.right.color, AppColors.highPriority);
  });

  testWidgets('EventCard renders correct colors for Medium priority', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventCard(
          event: event,
          priority: EventPriority.medium,
        ),
      ),
    ));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, AppColors.mediumPriorityBg);
    final border = decoration.border as Border;
    expect(border.right.color, AppColors.mediumPriority);
  });

  testWidgets('EventCard displays formatted time and date correctly in Hebrew locale', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventCard(
          event: event,
          priority: EventPriority.low,
        ),
      ),
    ));

    // DateFormat.Hm('he_IL') -> 14:30
    expect(find.text('14:30'), findsOneWidget);

    // DateFormat.MMMd('he_IL') -> 15 בנוב׳
    // Note: The actual text might depend on the implementation of intl for he_IL.
    // We should check if it contains the day and month roughly.
    // "15 בנוב׳"
    expect(find.text('15 בנוב׳'), findsOneWidget);
  });
}
