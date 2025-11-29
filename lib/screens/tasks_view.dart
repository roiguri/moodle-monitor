import 'package:flutter/material.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/services/preferences_service.dart';
import 'package:moodle_monitor/services/widget_service.dart';
import 'package:moodle_monitor/widgets/greeting_header.dart';
import 'package:moodle_monitor/widgets/summary_text.dart';
import 'package:moodle_monitor/widgets/event_section.dart';
import 'package:moodle_monitor/widgets/shimmer_loading_view.dart';
import 'package:moodle_monitor/widgets/error_state_view.dart';
import 'package:moodle_monitor/widgets/credentials_required_view.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/utils/course_utils.dart';
import 'package:moodle_monitor/utils/snackbar_helper.dart';
import '../constants/app_strings.dart';
import '../widgets/view_switcher.dart';

/// TasksView displays the user's deadlines and assignments
/// This is the main dashboard view showing upcoming tasks grouped by date or course
class TasksView extends StatefulWidget {
  final VoidCallback? onNavigateToSettings;
  final void Function(VoidCallback refresh)? onRefreshRequested;

  const TasksView({
    Key? key,
    this.onNavigateToSettings,
    this.onRefreshRequested,
  }) : super(key: key);

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late final MoodleClient _moodleClient;

  bool _isLoading = true;
  List<MoodleEvent>? _events;
  String? _errorMessage;
  bool _isAuthError = false;
  ViewType _selectedView = ViewType.day;

  void _onViewChanged(ViewType viewType) {
    setState(() {
      _selectedView = viewType;
    });
  }

  @override
  void initState() {
    super.initState();
    _moodleClient = MoodleClient();
    // Register refresh callback
    widget.onRefreshRequested?.call(_loadDeadlines);
    _loadDeadlines();
  }

  Future<void> _loadDeadlines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isAuthError = false;
    });

    try {
      final events = await _moodleClient.fetchDeadlines();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
          _errorMessage = null;
          _isAuthError = false; // Explicitly clear auth error on success
        });
        // Update widget after loading events
        WidgetService.updateWidget();
      }
    } on AuthException catch (e) {
      // Handle missing/invalid credentials gracefully
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isAuthError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isAuthError = false;
        });
        SnackbarHelper.showError(
          context,
          AppStrings.loadError,
          action: SnackBarAction(
            label: AppStrings.retryButton,
            onPressed: _loadDeadlines,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      final events = await _moodleClient.fetchDeadlines();
      if (mounted) {
        setState(() {
          _events = events;
          _errorMessage = null;
          _isAuthError = false; // Clear auth error on successful refresh
        });
        // Update widget after refreshing
        WidgetService.updateWidget();
      }
    } on AuthException catch (e) {
      // Handle missing/invalid credentials during refresh
      if (mounted) {
        // Don't change loading state during refresh
        setState(() {
          _errorMessage = e.toString();
          _isAuthError = true;
        });

        // Check if credentials actually exist to differentiate the error
        final hasCredentials = await _moodleClient.hasCredentials();
        
        if (!hasCredentials) {
          // Scenario 1: Credentials were removed/cleared
          if (_events != null && _events!.isNotEmpty) {
            // Show warning - keep cached tasks visible
            SnackbarHelper.showWarning(
              context,
              AppStrings.credentialsMissing,
              action: SnackBarAction(
                label: AppStrings.updateCredentialsButton,
                onPressed: widget.onNavigateToSettings ?? () {},
              ),
            );
          } else {
            // No cached data and no credentials
            SnackbarHelper.showWarning(
              context,
              AppStrings.firstLaunchMessage,
              action: SnackBarAction(
                label: AppStrings.goToSettingsButton,
                onPressed: widget.onNavigateToSettings ?? () {},
              ),
            );
          }
        } else {
          // Scenario 2: Credentials exist but are invalid/expired
          SnackbarHelper.showError(
            context,
            AppStrings.invalidCredentials,
            action: SnackBarAction(
              label: AppStrings.updateCredentialsButton,
              onPressed: widget.onNavigateToSettings ?? () {},
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isAuthError = false;
        });
        SnackbarHelper.showError(
          context,
          AppStrings.refreshError,
          action: SnackBarAction(
            label: AppStrings.retryButton,
            onPressed: _onRefresh,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoadingView();
    }

    // Show credentials required view if it's an auth error
    if (_isAuthError && _events == null) {
      // We need to determine if credentials are missing or invalid
      // This requires async check, so we use FutureBuilder
      return FutureBuilder<bool>(
        future: _moodleClient.hasCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoadingView();
          }
          
          final hasCredentials = snapshot.data ?? false;
          final errorType = hasCredentials
              ? CredentialsErrorType.invalid
              : CredentialsErrorType.missing;
          
          return CredentialsRequiredView(
            onGoToSettings: widget.onNavigateToSettings,
            errorType: errorType,
          );
        },
      );
    }

    if (_errorMessage != null && _events == null) {
      return ErrorStateView(
        errorMessage: _errorMessage,
        onRetry: _loadDeadlines,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder<List<MoodleEvent>>(
          future: _getVisibleEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildContentUI(_events ?? []);
            }
            return _buildContentUI(snapshot.data ?? []);
          },
        ),
      ),
    );
  }

  /// Filter events to exclude tasks from hidden courses
  Future<List<MoodleEvent>> _getVisibleEvents() async {
    if (_events == null) return [];
    
    try {
      final prefsService = await PreferencesService.getInstance();
      final hiddenCourses = await prefsService.getHiddenCourses();
      
      if (hiddenCourses.isEmpty) {
        return _events!;
      }
      
      return _events!.where((event) {
        return !hiddenCourses.contains(event.courseid.toString());
      }).toList();
    } catch (e) {
      // If there's any error loading preferences, return all events
      return _events!;
    }
  }

  Widget _buildContentUI(List<MoodleEvent> events) {
    final groupedEventsByDate = EventDateUtils.groupEventsByDate(events);
    final dayKeys = EventDateUtils.getSortedDayKeys(groupedEventsByDate);

    final groupedEventsByCourse = CourseUtils.groupEventsByCourse(events);
    final courseKeys = CourseUtils.getSortedCourseKeys(groupedEventsByCourse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GreetingHeader(
          trailingWidget: ViewSwitcher(onViewChanged: _onViewChanged),
        ),
        SummaryText(allEvents: events),
        if (_selectedView == ViewType.day) ...[
          ...dayKeys.map((dayKey) {
            final sectionEvents = groupedEventsByDate[dayKey]!;
            EventPriority priority;

            if (dayKey == AppStrings.today) {
              priority = EventPriority.high;
            } else if (dayKey == AppStrings.tomorrow) {
              priority = EventPriority.medium;
            } else {
              priority = EventPriority.low;
            }

            return EventSection(
              title: dayKey,
              events: sectionEvents,
              priority: priority,
              showCourse: true,
            );
          }),
          if (dayKeys.isEmpty) _buildEmptyState(),
        ] else ...[
          ...courseKeys.map((courseKey) {
            final sectionEvents = groupedEventsByCourse[courseKey]!;

            return EventSection(
              title: courseKey,
              events: sectionEvents,
              showCourse: false,
            );
          }),
          if (courseKeys.isEmpty) _buildEmptyState(),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        AppStrings.noTasks,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
