import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/constants/app_colors.dart';

class ShimmerEventCard extends StatelessWidget {
  final EventPriority priority;

  const ShimmerEventCard({
    Key? key,
    required this.priority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForPriority(priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: colors.border.withOpacity(0.3),
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 14,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ShimmerColors _getColorsForPriority(EventPriority priority) {
    switch (priority) {
      case EventPriority.high:
        return _ShimmerColors(
          background: AppColors.highPriorityBg,
          border: AppColors.highPriority,
        );
      case EventPriority.medium:
        return _ShimmerColors(
          background: AppColors.mediumPriorityBg,
          border: AppColors.mediumPriority,
        );
      case EventPriority.low:
        return _ShimmerColors(
          background: AppColors.lowPriorityBg,
          border: AppColors.lowPriority,
        );
    }
  }
}

class _ShimmerColors {
  final Color background;
  final Color border;

  _ShimmerColors({
    required this.background,
    required this.border,
  });
}
