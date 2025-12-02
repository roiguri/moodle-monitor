import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/widgets/moodle_credentials_form.dart';
import 'package:moodie/constants/app_strings.dart';

void main() {
  testWidgets('MoodleCredentialsForm validates empty fields', (WidgetTester tester) async {
    final urlController = TextEditingController();
    final tokenController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: MoodleCredentialsForm(
            urlController: urlController,
            tokenController: tokenController,
          ),
        ),
      ),
    ));

    // Trigger validation
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.urlRequired), findsOneWidget);
    expect(find.text(AppStrings.tokenRequired), findsOneWidget);
  });

  testWidgets('MoodleCredentialsForm validates invalid URL', (WidgetTester tester) async {
    final urlController = TextEditingController(text: 'invalid-url');
    final tokenController = TextEditingController(text: 'token');
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: MoodleCredentialsForm(
            urlController: urlController,
            tokenController: tokenController,
          ),
        ),
      ),
    ));

    // Trigger validation
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.urlInvalid), findsOneWidget);
    expect(find.text(AppStrings.tokenRequired), findsNothing);
  });
}
