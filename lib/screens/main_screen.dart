import 'package:flutter/material.dart';
import 'package:moodie/screens/tasks_view.dart';
import 'package:moodie/screens/courses_view.dart';
import 'package:moodie/screens/settings_view.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/utils/snackbar_helper.dart';
import 'package:moodie/services/notification_service.dart';

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
  VoidCallback? _refreshCourses;

  void _navigateToSettings() {
    setState(() {
      _selectedIndex = 2; // Settings tab
    });
  }

  void _onCredentialsSaved() {
    // Refresh both views after credentials are saved
    _refreshTasks?.call();
    _refreshCourses?.call();
  }

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
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
            SnackbarHelper.showWarning(
              context,
              AppStrings.firstLaunchMessage,
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
              onRefreshRequested: (refresh) => _refreshCourses = refresh,
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
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C2024) // charcoal-bg from design
              : const Color(0xFFF0F2F5), // Light grey for contrast
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
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.dashboard),
              ),
              label: AppStrings.navTasks,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.school_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.school),
              ),
              label: AppStrings.navCourses,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
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
