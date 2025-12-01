import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/services/notification_service.dart';
import 'package:moodie/services/preferences_service.dart';
import 'package:moodie/screens/onboarding/onboarding_page_layout.dart';

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
    return OnboardingPageLayout(
      image: Image.asset(
        'assets/images/notifications-screen-transparent.webp',
        width: double.infinity,
        fit: BoxFit.contain,
      ),
      title: AppStrings.onboardingPermissionsTitle,
      body: AppStrings.onboardingPermissionsBody,
      buttonText: AppStrings.onboardingPermissionsButton,
      onButtonPressed: _requestPermissions,
      isLoading: _isLoading,
      skipText: AppStrings.onboardingPermissionsSkip,
      onSkipPressed: _skipPermissions,
    );
  }
}
