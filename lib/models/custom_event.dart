import 'package:moodie/models/app_event.dart';

class CustomEvent implements AppEvent {
  final int? id;
  @override
  final String title;
  final String? description;
  @override
  final AppEventType type;
  final DateTime startTime;
  @override
  final bool isCompleted;

  CustomEvent({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'start_time': startTime.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory CustomEvent.fromMap(Map<String, dynamic> map) {
    return CustomEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: AppEventType.values.firstWhere((e) => e.toString() == map['type']),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      isCompleted: (map['is_completed'] ?? 0) == 1,
    );
  }

  @override
  String get uniqueId => 'custom_$id';

  @override
  DateTime get date => startTime;

  @override
  String get courseName => '';
}
