import 'dart:convert';
import 'package:moodie/models/app_event.dart';

enum RecurrenceType {
  none,
  daily,
  weekly
}

class CustomEvent {
  final int? id;
  final String title;
  final String? description;
  final AppEventType type;
  final DateTime startTime;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval;
  final List<int>? recurrenceDays;
  final DateTime? recurrenceEndDate;
  final int? recurrenceCount;
  final bool isCompleted;

  CustomEvent({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startTime,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceInterval = 1,
    this.recurrenceDays,
    this.recurrenceEndDate,
    this.recurrenceCount,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'start_time': startTime.millisecondsSinceEpoch,
      'recurrence_type': recurrenceType.toString(),
      'recurrence_interval': recurrenceInterval,
      'recurrence_days': recurrenceDays != null ? jsonEncode(recurrenceDays) : null,
      'recurrence_end_date': recurrenceEndDate?.millisecondsSinceEpoch,
      'recurrence_count': recurrenceCount,
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
      recurrenceType: RecurrenceType.values.firstWhere((e) => e.toString() == map['recurrence_type']),
      recurrenceInterval: map['recurrence_interval'] ?? 1,
      recurrenceDays: map['recurrence_days'] != null
          ? List<int>.from(jsonDecode(map['recurrence_days']))
          : null,
      recurrenceEndDate: map['recurrence_end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['recurrence_end_date'])
          : null,
      recurrenceCount: map['recurrence_count'],
      isCompleted: (map['is_completed'] ?? 0) == 1,
    );
  }
}

class CustomEventInstance implements AppEvent {
  final CustomEvent event;
  final DateTime instanceDate;
  final bool isCompletedInstance;

  CustomEventInstance({
    required this.event,
    required this.instanceDate,
    required this.isCompletedInstance,
  });

  @override
  String get uniqueId => 'custom_${event.id}_${instanceDate.millisecondsSinceEpoch}';

  @override
  String get title => event.title;

  @override
  DateTime get date => DateTime(
    instanceDate.year,
    instanceDate.month,
    instanceDate.day,
    event.startTime.hour,
    event.startTime.minute,
  );

  @override
  bool get isCompleted => isCompletedInstance;

  @override
  String get courseName => '';

  @override
  AppEventType get type => event.type;
}
