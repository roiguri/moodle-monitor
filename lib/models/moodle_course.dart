/// MoodleCourse represents a Moodle course
class MoodleCourse {
  final int id;
  final String fullName;
  final String shortName;
  final String? viewUrl;

  MoodleCourse({
    required this.id,
    required this.fullName,
    required this.shortName,
    this.viewUrl,
  });

  factory MoodleCourse.fromJson(Map<String, dynamic> json, {String? moodleUrl}) {
    // Construct the course URL: {moodleUrl}/course/view.php?id={courseId}
    String? constructedUrl;
    if (moodleUrl != null) {
      constructedUrl = '$moodleUrl/course/view.php?id=${json['id']}';
    }
    
    return MoodleCourse(
      id: json['id'] as int,
      fullName: json['fullname'] as String? ?? '',
      shortName: json['shortname'] as String? ?? '',
      viewUrl: constructedUrl,
    );
  }

  @override
  String toString() {
    return 'MoodleCourse(id: $id, fullName: $fullName, shortName: $shortName)';
  }
}
