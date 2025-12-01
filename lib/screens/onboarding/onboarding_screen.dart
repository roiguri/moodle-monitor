import 'package:flutter/material.dart';
import 'package:moodie/screens/main_screen.dart';
import 'package:moodie/screens/onboarding/config_page.dart';
import 'package:moodie/screens/onboarding/permissions_page.dart';
import 'package:moodie/screens/onboarding/welcome_page.dart';
import 'package:moodie/services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const OnboardingScreen({super.key, required this.onThemeChanged});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await PreferencesService.getInstance();
    await prefs.setIsOnboarded(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen(onThemeChanged: widget.onThemeChanged)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce flow
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            WelcomePage(onNext: _nextPage),
            OnboardingConfigPage(onNext: _nextPage),
            OnboardingPermissionsPage(onFinish: _finishOnboarding),
          ],
        ),
      ),
    );
  }
}
