import 'package:flutter/material.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/widgets/event_card.dart';
import 'package:moodle_monitor/constants/text_styles.dart';

class EventSection extends StatelessWidget {
  final String title;
  final List<MoodleEvent> events;
  final EventPriority? priority;
  final bool showCourse;

  const EventSection({
    Key? key,
    required this.title,
    required this.events,
    this.priority,
    this.showCourse = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyles.sectionHeader,
          ),
        ),
        ...events.map((event) {
          final eventPriority = priority ?? EventDateUtils.getPriority(
            DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000),
          );
          return EventCard(
            event: event,
            priority: eventPriority,
            showCourse: showCourse,
          );
        }),
      ],
    );
  }
}
