import 'package:flutter/material.dart';
import 'package:moodie/models/app_event.dart';
import 'package:moodie/utils/event_counter.dart';

class SummaryText extends StatelessWidget {
  final List<AppEvent> allEvents;

  const SummaryText({
    Key? key,
    required this.allEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = EventCounter.countEventsThisWeek(allEvents);
    final summaryText = EventCounter.getSummaryText(count);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        summaryText,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
