import 'package:flutter/material.dart';
import 'package:moodie/screens/main_screen.dart';
import 'package:moodie/screens/onboarding/config_page.dart';
import 'package:moodie/screens/onboarding/permissions_page.dart';
import 'package:moodie/screens/onboarding/welcome_page.dart';
import 'package:moodie/screens/onboarding/widget_page.dart';
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
  final int _totalPages = 4;

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

  void _previousPage() {
    _pageController.previousPage(
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

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (_currentPage > 0) {
              _previousPage();
              return false;
            }
            return true;
          },
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce flow
                onPageChanged: _onPageChanged,
                children: [
                  WelcomePage(onNext: _nextPage),
                  OnboardingConfigPage(onNext: _nextPage),
                  OnboardingPermissionsPage(onFinish: _nextPage),
                  WidgetPage(onNext: _finishOnboarding),
                ],
              ),
              // Back Button
              if (_currentPage > 0 && Theme.of(context).platform != TargetPlatform.android)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: dotColor),
                    onPressed: _previousPage,
                  ),
                ),
              // Progress Dots
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? dotColor
                            : dotColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
