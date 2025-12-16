import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/models/moodle_course.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/services/preferences_service.dart';
import 'package:moodie/utils/snackbar_helper.dart';
import 'package:moodie/utils/course_name_utils.dart';
import 'package:moodie/widgets/shimmer_courses_loading_view.dart';
import 'package:moodie/widgets/error_state_view.dart';
import 'package:moodie/widgets/credentials_required_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moodie/services/widget_service.dart';

/// CoursesView displays all user's courses with hide/show functionality
class CoursesView extends StatefulWidget {
  final VoidCallback? onNavigateToSettings;
  final void Function(VoidCallback refresh)? onRefreshRequested;

  const CoursesView({
    Key? key,
    this.onNavigateToSettings,
    this.onRefreshRequested,
  }) : super(key: key);

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final MoodleClient _moodleClient = MoodleClient();
  PreferencesService? _prefsService;

  List<MoodleCourse>? _courses;
  Set<String> _hiddenCourseIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthError = false;

  @override
  void initState() {
    super.initState();
    // Register refresh callback
    widget.onRefreshRequested?.call(_loadCourses);
    _initializeAndLoadCourses();
  }

  Future<void> _initializeAndLoadCourses() async {
    _prefsService = await PreferencesService.getInstance();
    await _loadHiddenCourses();
    
    // Only load courses if not already cached
    if (_courses == null) {
      await _loadCourses();
    }
  }

  Future<void> _loadHiddenCourses() async {
    if (_prefsService != null) {
      final hiddenCourses = await _prefsService!.getHiddenCourses();
      if (mounted) {
        setState(() {
          _hiddenCourseIds = hiddenCourses.toSet();
        });
      }
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isAuthError = false;
    });

    try {
      final courses = await _moodleClient.fetchCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
          _isAuthError = false;
        });
      }
    } on AuthException catch (e) {
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
          AppStrings.fetchCoursesError,
          action: SnackBarAction(
            label: AppStrings.retryButton,
            onPressed: _loadCourses,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadCourses();
    await _loadHiddenCourses();
  }

  Future<void> _toggleCourseVisibility(String courseId) async {
    if (_prefsService != null) {
      await _prefsService!.toggleCourseVisibility(courseId);
      await _loadHiddenCourses();
      // Update widget to reflect hidden course (requires fetch as we don't have events here)
      WidgetService.updateWidget();
    }
  }

  Future<void> _launchCourseUrl(String? url) async {
    if (url == null || url.isEmpty) {
      SnackbarHelper.showWarning(context, 'לא נמצא קישור לקורס');
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        SnackbarHelper.showError(context, 'לא ניתן לפתוח את הקישור');
      }
    } catch (e) {
      SnackbarHelper.showError(context, 'שגיאה בפתיחת הקישור');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerCoursesLoadingView();
    }

    if (_isAuthError && _courses == null) {
      return FutureBuilder<bool>(
        future: _moodleClient.hasCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerCoursesLoadingView();
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

    if (_errorMessage != null && _courses == null) {
      return ErrorStateView(
        errorMessage: _errorMessage,
        onRetry: _loadCourses,
      );
    }

    if (_courses == null || _courses!.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noCourses,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Separate visible and hidden courses
    final visibleCourses = _courses!.where((course) => 
      !_hiddenCourseIds.contains(course.id.toString())
    ).toList();
    
    final hiddenCourses = _courses!.where((course) => 
      _hiddenCourseIds.contains(course.id.toString())
    ).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          Text(
            AppStrings.myCoursesTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Visible courses
          ...visibleCourses.map((course) => _buildCourseCard(course, false)),
          
          // Hidden courses section (if any)
          if (hiddenCourses.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              AppStrings.hiddenCoursesSection,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ...hiddenCourses.map((course) => _buildCourseCard(course, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(MoodleCourse course, bool isHidden) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchCourseUrl(course.viewUrl),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Course icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isHidden 
                      ? Theme.of(context).disabledColor.withOpacity(0.1) 
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: isHidden 
                      ? Theme.of(context).disabledColor 
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              // Course details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course name (Hebrew only)
                    Text(
                      CourseNameUtils.extractHebrewName(course.fullName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isHidden 
                            ? Theme.of(context).disabledColor 
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    // Course number
                    if (CourseNameUtils.extractCourseNumber(course.fullName).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        CourseNameUtils.extractCourseNumber(course.fullName),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Visibility toggle button
              IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  color: isHidden 
                      ? Theme.of(context).disabledColor 
                      : Theme.of(context).colorScheme.primary,
                ),
                tooltip: isHidden ? AppStrings.showCourse : AppStrings.hideCourse,
                onPressed: () => _toggleCourseVisibility(course.id.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
