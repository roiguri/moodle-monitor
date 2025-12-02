import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPageLayout extends StatelessWidget {
  final Widget image;
  final String title;
  final String body;
  final Widget? content;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final String? skipText;
  final VoidCallback? onSkipPressed;

  const OnboardingPageLayout({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    this.content,
    required this.buttonText,
    this.onButtonPressed,
    this.isLoading = false,
    this.skipText,
    this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonColor = isDark ? Colors.white : const Color(0xFF2C2C2C);
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      child: Column(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: image,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              title,
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
                              body,
                              style: GoogleFonts.assistant(
                                textStyle: Theme.of(context).textTheme.bodyLarge,
                                color: textColor,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (content != null) ...[
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: content!,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading ? null : onButtonPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: buttonTextColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: buttonTextColor,
                                      ),
                                    )
                                  : Text(
                                      buttonText,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          if (skipText != null && onSkipPressed != null) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: onSkipPressed,
                              style: TextButton.styleFrom(
                                foregroundColor: textColor,
                              ),
                              child: Text(
                                skipText!,
                                style: GoogleFonts.assistant(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: textColor,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}
