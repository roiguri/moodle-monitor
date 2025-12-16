abstract class AppEvent {
  String get uniqueId;
  String get title;
  DateTime get date;
  bool get isCompleted;
  String get courseName;
  AppEventType get type;
}

enum AppEventType {
  moodleDeadline,
  customDeadline,
  customTask,
}
