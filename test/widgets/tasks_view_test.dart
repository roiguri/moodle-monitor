import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moodie/screens/tasks_view.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/widgets/shimmer_loading_view.dart';
import 'package:moodie/widgets/error_state_view.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../mocks.dart';

void main() {
  late MockMoodleClient mockClient;

  setUpAll(() async {
    await initializeDateFormatting('he_IL', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockMoodleClient();
  });

  testWidgets('TasksView displays ShimmerLoadingView initially and switches to list', (WidgetTester tester) async {
    // Arrange
    final event = MoodleEvent(
      id: 1,
      name: 'Event 1',
      course: 'Course 1',
      courseid: 1,
      timeSort: DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
      courseViewUrl: '',
      url: '',
    );

    when(() => mockClient.fetchDeadlines()).thenAnswer((_) async {
       await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
       return [event];
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TasksView(moodleClient: mockClient)),
    ));

    // Assert Initial State
    expect(find.byType(ShimmerLoadingView), findsOneWidget);

    // Act
    await tester.pumpAndSettle();

    // Assert Loaded State
    expect(find.byType(ShimmerLoadingView), findsNothing);
    expect(find.text('Event 1'), findsOneWidget);
  });

  testWidgets('TasksView shows ErrorStateView when fetch fails', (WidgetTester tester) async {
    // Arrange
    when(() => mockClient.fetchDeadlines()).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 10));
      throw Exception('Failed to load');
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TasksView(moodleClient: mockClient)),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(ErrorStateView), findsOneWidget);
    expect(find.text('Exception: Failed to load'), findsOneWidget);
    // Be specific about finding the retry button inside ErrorStateView
    expect(find.descendant(
      of: find.byType(ErrorStateView),
      matching: find.text('נסה שוב'),
    ), findsOneWidget);
  });
}
