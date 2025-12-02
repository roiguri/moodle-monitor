import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/widgets/greeting_header.dart';
import 'package:moodie/utils/greeting_helper.dart';

void main() {
  testWidgets('GreetingHeader displays greeting text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GreetingHeader(),
      ),
    ));

    final expectedGreeting = GreetingHelper.getGreeting(DateTime.now());

    expect(find.text(expectedGreeting), findsOneWidget);
  });

  testWidgets('GreetingHeader displays default logo when no trailing widget provided', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GreetingHeader(),
      ),
    ));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('GreetingHeader displays trailing widget when provided', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GreetingHeader(
          trailingWidget: Icon(Icons.settings),
        ),
      ),
    ));

    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
