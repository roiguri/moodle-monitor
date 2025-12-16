import 'package:moodie/utils/course_name_utils.dart';
import 'package:moodie/models/app_event.dart';

class MoodleEvent implements AppEvent {
  final int id;
  final String name;
  final String course;
  final int courseid;
  final int timeSort;
  final String courseViewUrl;
  final String url;
  final int? cmid; // Course Module ID (for completion API)

  MoodleEvent({
    required this.id,
    required this.name,
    required this.course,
    required this.courseid,
    required this.timeSort,
    required this.courseViewUrl,
    required this.url,
    this.cmid,
  });

  factory MoodleEvent.fromJson(Map<String, dynamic> json) {
    // Try to find cmid in the instance parameter or parse from URL
    int? parsedCmid;
    
    // Check if 'course' object has the module id (common in some API versions)
    if (json['course'] != null && json['course']['coursemoduleid'] != null) {
      parsedCmid = json['course']['coursemoduleid'];
    }
    
    // Fallback: Try to parse 'id' parameter from the view URL
    // e.g., "https://moodle.tau.ac.il/mod/assign/view.php?id=12345"
    if (parsedCmid == null && json['url'] != null) {
      try {
        final uri = Uri.parse(json['url']);
        final idParam = uri.queryParameters['id'];
        if (idParam != null) {
          parsedCmid = int.tryParse(idParam);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return MoodleEvent(
      id: json['id'] as int,
      name: json['activityname'] as String,
      course: CourseNameUtils.cleanCourseName(json['course']['shortname'] as String),
      courseid: json['course']['id'] as int,
      timeSort: json['timesort'] as int,
      courseViewUrl: json['course']['viewurl'] as String,
      url: json['url'] as String,
      cmid: parsedCmid,
    );
  }

  @override
  String get uniqueId => 'moodle_$id';

  @override
  String get title => name;

  @override
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timeSort * 1000);

  @override
  bool get isCompleted => false; // Moodle events fetched are typically incomplete

  @override
  String get courseName => course;

  @override
  AppEventType get type => AppEventType.moodleDeadline;
}
