import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moodie/screens/courses_view.dart';
import 'package:moodie/models/moodle_course.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks.dart';

void main() {
  late MockMoodleClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockMoodleClient();
  });

  testWidgets('CoursesView renders separate lists for visible and hidden courses', (WidgetTester tester) async {
    final visibleCourse = MoodleCourse(id: 1, fullName: 'Visible Course', shortName: 'VC');
    final hiddenCourse = MoodleCourse(id: 2, fullName: 'Hidden Course', shortName: 'HC');

    when(() => mockClient.fetchCourses()).thenAnswer((_) async => [visibleCourse, hiddenCourse]);

    // Set hidden course in prefs
    SharedPreferences.setMockInitialValues({
      'hidden_courses': ['2'],
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CoursesView(moodleClient: mockClient)),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Visible Course'), findsOneWidget);
    expect(find.text('Hidden Course'), findsOneWidget);

    // Check for section headers or visual separation
    // "Hidden Courses" section header
    expect(find.text(AppStrings.hiddenCoursesSection), findsOneWidget);
  });

  testWidgets('Tapping visibility icon updates state', (WidgetTester tester) async {
    final course = MoodleCourse(id: 1, fullName: 'Test Course', shortName: 'TC');

    when(() => mockClient.fetchCourses()).thenAnswer((_) async => [course]);
    SharedPreferences.setMockInitialValues({}); // No hidden courses

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CoursesView(moodleClient: mockClient)),
    ));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Tap to hide
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();

    // Now it should be hidden
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.text(AppStrings.hiddenCoursesSection), findsOneWidget);
  });
}
