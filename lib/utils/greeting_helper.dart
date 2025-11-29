import 'package:moodie/constants/app_strings.dart';

class GreetingHelper {
  static String getGreeting(DateTime time) {
    final hour = time.hour;

    if (hour >= 5 && hour < 12) {
      return '${AppStrings.goodMorning}!'; // 5:00-11:59
    } else if (hour >= 12 && hour < 17) {
      return '${AppStrings.goodAfternoon}!'; // 12:00-16:59
    } else if (hour >= 17 && hour < 21) {
      return '${AppStrings.goodEvening}!'; // 17:00-20:59
    } else {
      return '${AppStrings.goodNight}!'; // 21:00-4:59
    }
  }
}
