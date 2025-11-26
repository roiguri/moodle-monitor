import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/constants/app_colors.dart';
import 'package:moodle_monitor/constants/text_styles.dart';

class EventCard extends StatelessWidget {
  final MoodleEvent event;
  final EventPriority priority;
  final bool showCourse;

  const EventCard({
    Key? key,
    required this.event,
    required this.priority,
    this.showCourse = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForPriority(priority);
    final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
    final formattedTime = DateFormat.Hm('he_IL').format(deadline);
    final formattedDate = DateFormat.MMMd('he_IL').format(deadline);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: showCourse
        ? null
        : const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: colors.border,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: showCourse
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
          children: [
            // Event name and course info (switched order)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.name,
                    style: TextStyles.cardCourse.copyWith(
                      color: colors.text,
                    ),
                  ),
                  if (showCourse) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.course,
                      style: TextStyles.cardEvent,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: TextStyles.cardTime.copyWith(
                    color: colors.accent,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _CardColors _getColorsForPriority(EventPriority priority) {
    switch (priority) {
      case EventPriority.high:
        return _CardColors(
          background: AppColors.highPriorityBg,
          border: AppColors.highPriority,
          text: Colors.black87,
          accent: AppColors.highPriority,
        );
      case EventPriority.medium:
        return _CardColors(
          background: AppColors.mediumPriorityBg,
          border: AppColors.mediumPriority,
          text: Colors.black87,
          accent: AppColors.mediumPriority,
        );
      case EventPriority.low:
        return _CardColors(
          background: AppColors.lowPriorityBg,
          border: AppColors.lowPriority,
          text: Colors.black87,
          accent: AppColors.lowPriority,
        );
    }
  }
}

class _CardColors {
  final Color background;
  final Color border;
  final Color text;
  final Color accent;

  _CardColors({
    required this.background,
    required this.border,
    required this.text,
    required this.accent,
  });
}
