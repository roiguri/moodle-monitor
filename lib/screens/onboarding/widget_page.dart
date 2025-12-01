import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/screens/onboarding/onboarding_page_layout.dart';

class WidgetPage extends StatelessWidget {
  final VoidCallback onNext;

  const WidgetPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      image: Image.asset(
        'assets/images/tasks-screen-transparent.webp',
        width: double.infinity,
        fit: BoxFit.contain,
      ),
      title: AppStrings.onboardingWidgetTitle,
      body: AppStrings.onboardingWidgetBody,
      buttonText: AppStrings.onboardingWidgetButton,
      onButtonPressed: onNext,
    );
  }
}
