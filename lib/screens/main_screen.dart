import 'package:flutter/material.dart';
import 'package:moodle_monitor/screens/tasks_view.dart';
import 'package:moodle_monitor/screens/courses_view.dart';
import 'package:moodle_monitor/screens/settings_view.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/constants/app_strings.dart';

/// MainScreen is the primary navigation container
/// Manages bottom navigation bar and view switching
class MainScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const MainScreen({
    Key? key,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final _moodleClient = MoodleClient();
  bool _isCheckingCredentials = true;
  VoidCallback? _refreshTasks;

  void _navigateToSettings() {
    setState(() {
      _selectedIndex = 2; // Settings tab
    });
  }

  void _onCredentialsSaved() {
    // Refresh TasksView after credentials are saved
    _refreshTasks?.call();
    // Navigate to Dashboard tab
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
    final hasCredentials = await _moodleClient.hasCredentials();

    if (mounted) {
      setState(() {
        _isCheckingCredentials = false;

        // If no credentials, redirect to Settings tab
        if (!hasCredentials) {
          _selectedIndex = 2; // Settings tab
        }
      });

      // Show a message if credentials are missing
      if (!hasCredentials) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please configure your Moodle credentials to get started',
                ),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingCredentials) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            TasksView(
              onNavigateToSettings: _navigateToSettings,
              onRefreshRequested: (refresh) => _refreshTasks = refresh,
            ),
            CoursesView(
              onNavigateToSettings: _navigateToSettings,
            ),
            SettingsView(
              onCredentialsSaved: _onCredentialsSaved,
              onThemeChanged: widget.onThemeChanged,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C2024) // charcoal-bg from design
              : Colors.white,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF9BA3AF) // blue-gray-secondary from design
              : Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            height: 1.5,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard),
              ),
              label: AppStrings.navTasks,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.school_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.school),
              ),
              label: AppStrings.navCourses,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings),
              ),
              label: AppStrings.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
