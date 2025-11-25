class MoodleEvent {
  final String name;
  final String course;
  final int timeSort;
  final String courseViewUrl;
  final String url;

  MoodleEvent({
    required this.name,
    required this.course,
    required this.timeSort,
    required this.courseViewUrl,
    required this.url,
  });

  factory MoodleEvent.fromJson(Map<String, dynamic> json) {
    return MoodleEvent(
      name: json['activityname'] as String,
      course: json['course']['shortname'] as String,
      timeSort: json['timesort'] as int,
      courseViewUrl: json['course']['viewurl'] as String,
      url: json['url'] as String,
    );
  }
}
