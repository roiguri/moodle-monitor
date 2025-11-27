import 'package:flutter/material.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/services/widget_service.dart';
import 'package:moodle_monitor/widgets/greeting_header.dart';
import 'package:moodle_monitor/widgets/summary_text.dart';
import 'package:moodle_monitor/widgets/event_section.dart';
import 'package:moodle_monitor/widgets/shimmer_loading_view.dart';
import 'package:moodle_monitor/widgets/error_state_view.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/utils/course_utils.dart';
import '../constants/app_strings.dart';
import '../widgets/view_switcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodleClient _moodleClient;

  bool _isLoading = true;
  List<MoodleEvent>? _events;
  String? _errorMessage;
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
    _loadDeadlines();
  }

  Future<void> _loadDeadlines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _moodleClient.fetchDeadlines();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
        // Update widget after loading events
        WidgetService.updateWidget();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        _showErrorSnackBar();
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
        });
        // Update widget after refreshing
        WidgetService.updateWidget();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        _showRefreshErrorSnackBar();
      }
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.loadError),
        action: SnackBarAction(
          label: AppStrings.retryButton,
          onPressed: _loadDeadlines,
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _showRefreshErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.refreshError),
        action: SnackBarAction(
          label: AppStrings.retryButton,
          onPressed: _onRefresh,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoadingView();
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final events = _events ?? [];
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
