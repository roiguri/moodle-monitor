import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/screens/onboarding/onboarding_page_layout.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      image: Image.asset(
        'assets/images/introduction-screen-transparent.webp',
        fit: BoxFit.fitWidth,
      ),
      title: AppStrings.onboardingWelcomeTitle,
      body: AppStrings.onboardingWelcomeBody,
      buttonText: AppStrings.onboardingNext,
      onButtonPressed: onNext,
    );
  }
}
