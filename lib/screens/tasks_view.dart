import 'package:flutter/material.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/services/preferences_service.dart';
import 'package:moodie/services/widget_service.dart';
import 'package:moodie/widgets/greeting_header.dart';
import 'package:moodie/widgets/summary_text.dart';
import 'package:moodie/widgets/event_section.dart';
import 'package:moodie/widgets/shimmer_loading_view.dart';
import 'package:moodie/widgets/error_state_view.dart';
import 'package:moodie/widgets/credentials_required_view.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:moodie/utils/course_utils.dart';
import 'package:moodie/utils/snackbar_helper.dart';
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
  Set<String> _ignoredEventIds = {};
  bool _showHidden = false;

  void _onViewChanged(ViewType viewType) {
    setState(() {
      _selectedView = viewType;
    });
  }

  @override
  void initState() {
    super.initState();
    _moodleClient = MoodleClient();
    _loadIgnoredEvents();
    // Register refresh callback
    widget.onRefreshRequested?.call(_loadDeadlines);
    _loadDeadlines();
  }

  Future<void> _loadIgnoredEvents() async {
    final prefs = await PreferencesService.getInstance();
    final ignored = await prefs.getIgnoredEvents();
    if (mounted) {
      setState(() {
        _ignoredEventIds = ignored.toSet();
      });
    }
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
        
        // Cleanup stale ignored events
        final prefs = await PreferencesService.getInstance();
        await prefs.cleanupIgnoredEvents(events.map((e) => e.id.toString()).toList());
        
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
      
      return _events!.where((event) {
        return MoodleClient.isEventVisible(
          event, 
          hiddenCourses, 
          _ignoredEventIds.toList(), // Convert Set to List
        );
      }).toList();
    } catch (e) {
      // If there's any error loading preferences, return all events
      return _events!;
    }
  }

  /// Get list of ignored events that are still relevant (not past deadline, etc)
  List<MoodleEvent> _getHiddenEvents() {
    if (_events == null) return [];
    return _events!.where((event) {
      return _ignoredEventIds.contains(event.id.toString());
    }).toList();
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
              onIgnore: _handleIgnoreTask,
              onMarkDone: _handleMarkAsDone,
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
              onIgnore: _handleIgnoreTask,
              onMarkDone: _handleMarkAsDone,
            );
          }),
          if (courseKeys.isEmpty) _buildEmptyState(),
        ],
        const SizedBox(height: 4),
        
        // Hidden Tasks Section
        if (_ignoredEventIds.isNotEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showHidden = !_showHidden;
                  });
                },
                icon: Icon(
                  _showHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                label: Text(
                  _showHidden ? AppStrings.hideHiddenTasks : AppStrings.showHiddenTasks,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          if (_showHidden)
            EventSection(
              title: '',
              events: _getHiddenEvents(),
              showCourse: true,
              onRestore: _handleRestoreTask,
            ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_tasks_transparent.webp',
            width: MediaQuery.of(context).size.width-40,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Future<void> _handleIgnoreTask(MoodleEvent event) async {
    final prefs = await PreferencesService.getInstance();
    await prefs.ignoreEvent(event.id);
    await _loadIgnoredEvents(); // Refresh state to hide card immediately
    
    // Update widget instantly using cached events
    await WidgetService.updateWidget(cachedEvents: _events);

    if (mounted) {
      SnackbarHelper.showInfo(context, AppStrings.taskHidden);
    }
  }

  Future<void> _handleRestoreTask(MoodleEvent event) async {
    final prefs = await PreferencesService.getInstance();
    await prefs.unignoreEvent(event.id);
    await _loadIgnoredEvents();
    
    // Update widget instantly using cached events
    await WidgetService.updateWidget(cachedEvents: _events);

    if (mounted) {
      SnackbarHelper.showSuccess(context, AppStrings.taskRestored);
    }
  }

  Future<void> _handleMarkAsDone(MoodleEvent event) async {
    if (event.cmid == null) {
      SnackbarHelper.showError(context, AppStrings.taskMarkingErrorMissingId);
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.taskMarkingInProgress), duration: Duration(seconds: 1)),
      );

      final success = await _moodleClient.updateActivityCompletion(event.cmid!, true);
      
      if (success) {
        if (mounted) {
          SnackbarHelper.showSuccess(context, AppStrings.taskMarkedAsDone);
          // Refresh the list from Moodle - the task should disappear from the API response
          _onRefresh(); 
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, AppStrings.taskMarkingError);
      }
    }
  }
}
