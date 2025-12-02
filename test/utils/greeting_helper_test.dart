import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/utils/greeting_helper.dart';
import 'package:moodie/constants/app_strings.dart';

void main() {
  group('GreetingHelper', () {
    test('getGreeting returns morning greeting', () {
      final time = DateTime(2023, 1, 1, 8, 0); // 8:00 AM
      expect(GreetingHelper.getGreeting(time), '${AppStrings.goodMorning}!');
    });

    test('getGreeting returns afternoon greeting', () {
      final time = DateTime(2023, 1, 1, 14, 0); // 2:00 PM
      expect(GreetingHelper.getGreeting(time), '${AppStrings.goodAfternoon}!');
    });

    test('getGreeting returns evening greeting', () {
      final time = DateTime(2023, 1, 1, 19, 0); // 7:00 PM
      expect(GreetingHelper.getGreeting(time), '${AppStrings.goodEvening}!');
    });

    test('getGreeting returns night greeting', () {
      final time = DateTime(2023, 1, 1, 23, 0); // 11:00 PM
      expect(GreetingHelper.getGreeting(time), '${AppStrings.goodNight}!');
    });
  });
}
