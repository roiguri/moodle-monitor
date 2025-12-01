import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/app_strings.dart';

class WidgetPage extends StatelessWidget {
  final VoidCallback onNext;

  const WidgetPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonColor = isDark ? Colors.white : const Color(0xFF2C2C2C);
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Column(
      children: [
        const SizedBox(height: 60),
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/images/tasks-screen-transparent.webp',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  AppStrings.onboardingWidgetTitle,
                  style: GoogleFonts.assistant(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  AppStrings.onboardingWidgetBody,
                  style: GoogleFonts.assistant(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    color: textColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                AppStrings.onboardingWidgetButton,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 64),
      ],
    );
  }
}
