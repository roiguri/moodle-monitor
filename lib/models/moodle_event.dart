class MoodleEvent {
  final String name;
  final String course;
  final int courseid;
  final int timeSort;
  final String courseViewUrl;
  final String url;

  MoodleEvent({
    required this.name,
    required this.course,
    required this.courseid,
    required this.timeSort,
    required this.courseViewUrl,
    required this.url,
  });

  factory MoodleEvent.fromJson(Map<String, dynamic> json) {
    return MoodleEvent(
      name: json['activityname'] as String,
      course: _cleanCourseName(json['course']['shortname'] as String),
      courseid: json['course']['id'] as int,
      timeSort: json['timesort'] as int,
      courseViewUrl: json['course']['viewurl'] as String,
      url: json['url'] as String,
    );
  }

  static String _cleanCourseName(String name) {
    // This regex splits the string by course codes like "0512426201 - "
    final parts = name.split(RegExp(r'\d+\s*-\s*'));
    
    final cleanedParts = parts
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          String cleaned = part.trim();
          // Strip dashes from the end
          while (cleaned.endsWith('-')) {
            cleaned = cleaned.substring(0, cleaned.length - 1).trimRight();
          }
          // Replace remaining dashes with a space and normalize whitespace
          return cleaned.replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        })
        .where((part) => part.isNotEmpty);

    // Join the remaining parts with a separator
    return cleanedParts.join(' / ');
  }
}
