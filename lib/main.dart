import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moodie/screens/main_screen.dart';
import 'package:moodie/screens/onboarding/onboarding_screen.dart';
import 'package:moodie/services/widget_service.dart';
import 'package:moodie/constants/app_theme.dart';
import 'package:moodie/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('he_IL', null);
  await WidgetService.initialize();
  runApp(const MoodieApp());
}

class MoodieApp extends StatefulWidget {
  const MoodieApp({super.key});

  @override
  State<MoodieApp> createState() => _MoodieAppState();
}

class _MoodieAppState extends State<MoodieApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool? _isOnboarded;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await PreferencesService.getInstance();
    final savedTheme = prefs.getThemeMode();
    final isOnboarded = prefs.getIsOnboarded();
    
    if (mounted) {
      setState(() {
        _themeMode = _getThemeModeFromString(savedTheme);
        _isOnboarded = isOnboarded;
      });
    }
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _changeTheme(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    
    final prefs = await PreferencesService.getInstance();
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    await prefs.setThemeMode(themeString);
  }

  @override
  Widget build(BuildContext context) {
    // Show splash or loading while checking preferences
    if (_isOnboarded == null) {
      return MaterialApp(
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Moodie',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew, Israel
        Locale('en', 'US'), // English, United States
      ],
      locale: const Locale('he', 'IL'),
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: _themeMode,
      home: _isOnboarded! 
          ? MainScreen(onThemeChanged: _changeTheme)
          : OnboardingScreen(onThemeChanged: _changeTheme),
    );
  }
}
