// integration_test/app_test.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:moodie/main.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Definition of handler type
typedef MockClientHandler = Future<http.Response> Function(http.Request request);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --- Mocks Setup ---
  final futureTime = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;

  final eventsJson = jsonEncode({
    "events": [
      {
        "id": 101,
        "name": "Task 1",
        "description": "Description 1",
        "course": {"id": 10, "fullname": "Course A", "shortname": "CS101"},
        "timesort": futureTime,
        "modulename": "assign",
        "cmid": 1001,
        "url": "http://example.com/task1",
        "action": {"actionable": true}
      },
      {
        "id": 102,
        "name": "Task 2",
        "course": {"id": 20, "fullname": "Course B", "shortname": "CS102"},
        "timesort": futureTime + 3600,
        "modulename": "quiz",
        "cmid": 1002,
        "url": "http://example.com/task2",
        "action": {"actionable": true}
      }
    ]
  });

  final coursesJson = jsonEncode([
    {"id": 10, "fullname": "Course A", "shortname": "CS101"},
    {"id": 20, "fullname": "Course B", "shortname": "CS102"}
  ]);

  final siteInfoJson = jsonEncode({
    "userid": 1,
    "fullname": "Test User",
    "siteurl": "https://moodle.example.com"
  });

  // Client Factory that allows changing behavior
  MockClientHandler? currentHandler;

  final client = MockClient((request) async {
    if (currentHandler != null) {
      return currentHandler!(request);
    }
    return http.Response('Not Found', 404);
  });

  // Default Handler
  Future<http.Response> defaultHandler(http.Request request) async {
    final url = request.url.toString();
    if (url.contains('core_webservice_get_site_info')) {
      return http.Response(siteInfoJson, 200);
    }
    if (url.contains('core_calendar_get_action_events_by_timesort')) {
      return http.Response(eventsJson, 200);
    }
    if (url.contains('core_enrol_get_users_courses')) {
      return http.Response(coursesJson, 200);
    }
    if (url.contains('core_completion_update_activity_completion_status_manually')) {
      return http.Response(jsonEncode({"status": true}), 200);
    }
    return http.Response('Not Found', 404);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    currentHandler = defaultHandler;
  });

  patrolTest(
    'User Journeys: Onboarding, Auth, Core Usage',
    ($) async {
      await http.runWithClient(() async {
        await $.pumpWidgetAndSettle(const MoodieApp());

        // --- Flow: First Launch ---
        // Verify Onboarding
        expect($(AppStrings.onboardingWelcomeTitle), findsOneWidget);
        await $(AppStrings.onboardingContinue).tap();
        await $.pumpAndSettle();
        await $(AppStrings.onboardingContinue).tap();
        await $.pumpAndSettle();
        await $(AppStrings.onboardingPermissionsSkip).tap();
        await $.pumpAndSettle();
        await $(AppStrings.onboardingWidgetButton).tap();
        await $.pumpAndSettle();

        // --- Verify redirection to MainScreen with Credentials Required ---
        expect($(AppStrings.credentialsRequiredTitle), findsOneWidget);

        // --- Flow: Login Error ---
        await $(AppStrings.goToSettingsButton).tap();
        await $.pumpAndSettle();
        expect($(AppStrings.settingsTitle), findsOneWidget);

        // Inject Error Behavior
        currentHandler = (request) async {
          if (request.url.toString().contains('core_webservice_get_site_info')) {
             return http.Response(jsonEncode({"exception": "moodle_exception", "message": "Invalid token"}), 200);
          }
          return defaultHandler(request);
        };

        await $(AppStrings.moodleUrlLabel).enterText('https://moodle.example.com');
        await $(AppStrings.moodleTokenLabel).enterText('invalid-token');
        await $.pump();

        await $(AppStrings.saveButton).tap();
        await $.pumpAndSettle();

        // Verify Error
        expect($(AppStrings.validationInvalidToken), findsOneWidget);

        // --- Flow: Login Success ---
        // Reset Handler
        currentHandler = defaultHandler;

        await $(AppStrings.moodleTokenLabel).enterText('valid-token');
        await $.pump();

        await $(AppStrings.saveButton).tap();
        await $.pumpAndSettle();

        // Verify Success Message
        expect($(AppStrings.credentialsSaved), findsOneWidget);

        // Navigate to Tasks Tab
        await $(AppStrings.navTasks).tap();
        await $.pumpAndSettle();

        // --- Flow: Task Management ---
        // Verify Tasks Loaded
        expect($('Task 1'), findsOneWidget);
        expect($('Task 2'), findsOneWidget);

        // Swipe Task 1 to Ignore (Right)
        await $.tester.drag(find.byKey(const Key('event_101')), const Offset(500, 0));
        await $.pumpAndSettle();

        // Verify Task 1 is gone
        expect($('Task 1'), findsNothing);
        // Verify Task 2 is still there
        expect($('Task 2'), findsOneWidget);

        // --- Flow: Course Filtering ---
        // Go to Courses Tab
        await $(AppStrings.navCourses).tap();
        await $.pumpAndSettle();

        // Verify Courses
        expect($('Course A'), findsOneWidget);
        expect($('Course B'), findsOneWidget);

        // Hide Course B (Second course)
        final courseBCard = find.ancestor(
          of: find.text('Course B'),
          matching: find.byType(Card),
        );
        final visibilityIcon = find.descendant(
          of: courseBCard,
          matching: find.byIcon(Icons.visibility),
        );
        await $(visibilityIcon).tap();
        await $.pumpAndSettle();

        // Return to Tasks View
        await $(AppStrings.navTasks).tap();
        await $.pumpAndSettle();

        // Verify tasks from Course B (Task 2) are gone.
        // Task 1 was ignored, so it's gone.
        // Task 2 is from Course B.
        // So list should be empty or show "No tasks".
        expect($('Task 2'), findsNothing);

        // --- Flow: Navigation & State Retention ---
        // Go back to settings.
        await $(AppStrings.navSettings).tap();
        await $.pumpAndSettle();
        expect($(AppStrings.settingsTitle), findsOneWidget);

        // --- Flow: Theme Switching ---
        // Change to Dark
        await $(AppStrings.themeModeDark).tap();
        await $.pumpAndSettle();

        // Verify icon is visible (selected)
        expect($(Icons.dark_mode_outlined), findsOneWidget);

      }, () => client);
    },
  );
}
