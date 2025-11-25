import 'package:flutter/material.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/widgets/event_card.dart';
import 'package:moodle_monitor/constants/text_styles.dart';

class EventSection extends StatelessWidget {
  final String title;
  final List<MoodleEvent> events;
  final EventPriority priority;

  const EventSection({
    Key? key,
    required this.title,
    required this.events,
    required this.priority,
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
        ...events.map((event) => EventCard(
              event: event,
              priority: priority,
            )),
      ],
    );
  }
}
