import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/services/notification_service.dart';
import 'package:moodie/services/preferences_service.dart';

class OnboardingPermissionsPage extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPermissionsPage({super.key, required this.onFinish});

  @override
  State<OnboardingPermissionsPage> createState() => _OnboardingPermissionsPageState();
}

class _OnboardingPermissionsPageState extends State<OnboardingPermissionsPage> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {      
      final notificationService = NotificationService();
      await notificationService.requestPermissions();
      
      // Enable notifications in preferences
      final prefs = await PreferencesService.getInstance();
      await prefs.setNotifyNewTasks(true);
      await prefs.setNotifyDeadlines(true);
      await prefs.setDeadlineAlerts([60, 1440]); // 1 hour and 1 day before
      
      if (mounted) {
        widget.onFinish();
      }
    } catch (e) {
      // Handle error or just proceed
      if (mounted) {
        widget.onFinish();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipPermissions() {
    widget.onFinish();
  }

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
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Image.asset(
                    'assets/images/notifications-screen-transparent.webp',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  AppStrings.onboardingPermissionsTitle,
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
                  AppStrings.onboardingPermissionsBody,
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
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _requestPermissions,
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: buttonTextColor,
                          ),
                        )
                      : const Text(
                          AppStrings.onboardingPermissionsButton,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _skipPermissions,
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                child: Text(
                  AppStrings.onboardingPermissionsSkip,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: textColor,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
