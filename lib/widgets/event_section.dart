import 'package:flutter/material.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:moodie/widgets/event_card.dart';
import 'package:moodie/constants/text_styles.dart';
import 'package:moodie/constants/app_strings.dart';

class EventSection extends StatelessWidget {
  final String title;
  final List<MoodleEvent> events;
  final EventPriority? priority;
  final bool showCourse;
  final Function(MoodleEvent)? onIgnore;
  final Function(MoodleEvent)? onMarkDone;
  final Function(MoodleEvent)? onRestore;

  const EventSection({
    Key? key,
    required this.title,
    required this.events,
    this.priority,
    this.showCourse = true,
    this.onIgnore,
    this.onMarkDone,
    this.onRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Center(
              child: Text(
                title,
                style: TextStyles.sectionHeader,
              ),
            ),
          ),
        ...events.map((event) {
          final eventPriority = priority ?? EventDateUtils.getPriority(
            DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000),
          );
          
          return Dismissible(
            key: Key('event_${event.id}'),
            background: onRestore != null
                ? _buildSwipeAction(
                    Icons.restore,
                    AppStrings.restoreTask,
                    Alignment.centerRight,
                    Colors.blue,
                  )
                : _buildSwipeAction(
                    Icons.visibility_off,
                    AppStrings.hideTask,
                    Alignment.centerRight,
                    Colors.grey,
                  ),
            secondaryBackground: onRestore != null
                ? _buildSwipeAction(
                    Icons.restore,
                    AppStrings.restoreTask,
                    Alignment.centerLeft,
                    Colors.blue,
                  )
                : _buildSwipeAction(
                    Icons.check,
                    AppStrings.markAsDone,
                    Alignment.centerLeft,
                    Colors.green,
                  ),
            confirmDismiss: (direction) async {
              if (onRestore != null) {
                onRestore!(event);
                return true;
              }

              if (direction == DismissDirection.startToEnd) {
                // Swipe Right: Ignore
                if (onIgnore != null) {
                  onIgnore!(event);
                  return true; 
                }
              } else if (direction == DismissDirection.endToStart) {
                // Swipe Left: Mark as Done
                if (onMarkDone != null) {
                  onMarkDone!(event);
                  return false;
                }
              }
              return false;
            },
            child: EventCard(
              event: event,
              priority: eventPriority,
              showCourse: showCourse,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSwipeAction(IconData icon, String label, Alignment alignment, Color color) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
