
class MoodleEvent {
  final String name;
  final String course;
  final int timeSort;

  MoodleEvent({
    required this.name,
    required this.course,
    required this.timeSort,
  });

  factory MoodleEvent.fromJson(Map<String, dynamic> json) {
    return MoodleEvent(
      name: json['name'] as String,
      course: json['course']['fullname'] as String,
      timeSort: json['timesort'] as int,
    );
  }
}
