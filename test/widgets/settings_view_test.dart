import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moodie/screens/settings_view.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks.dart';

void main() {
  late MockMoodleClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockMoodleClient();
  });

  testWidgets('SettingsView displays current preferences correctly upon load', (WidgetTester tester) async {
    // Setup Mock Prefs
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'notify_new_tasks': true,
      'notify_deadlines': false,
    });

    // MoodleClient stubs
    when(() => mockClient.getMoodleUrl()).thenAnswer((_) async => 'http://example.com');
    when(() => mockClient.getMoodleToken()).thenAnswer((_) async => 'token123');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SettingsView(moodleClient: mockClient)),
    ));

    await tester.pumpAndSettle();

    // Verify Theme
    final segmentedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>));
    expect(segmentedButton.selected, {ThemeMode.dark});

    // Verify Notifications Switches
    final newTaskSwitch = find.widgetWithText(SwitchListTile, AppStrings.notifyNewTasks);
    expect(tester.widget<SwitchListTile>(newTaskSwitch).value, isTrue);

    final deadlinesSwitch = find.widgetWithText(SwitchListTile, AppStrings.notifyDeadlines);
    expect(tester.widget<SwitchListTile>(deadlinesSwitch).value, isFalse);

    // Verify Credentials
    expect(find.text('http://example.com'), findsOneWidget);
    expect(find.text('token123'), findsOneWidget);
  });
}
