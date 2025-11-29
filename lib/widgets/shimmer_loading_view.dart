import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moodie/widgets/greeting_header.dart';
import 'package:moodie/widgets/shimmer_event_card.dart';
import 'package:moodie/widgets/view_switcher.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:moodie/constants/app_strings.dart';

class ShimmerLoadingView extends StatelessWidget {
  const ShimmerLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final containerColor = isDark ? Colors.grey[850] : Colors.white;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingHeader(
            trailingWidget: ViewSwitcher(onViewChanged: (_) {}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 16,
                width: 200,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          _buildShimmerSection(context, AppStrings.today, EventPriority.high, 2),
          _buildShimmerSection(context, AppStrings.tomorrow, EventPriority.medium, 2),
          _buildShimmerSection(context, AppStrings.next7Days, EventPriority.low, 1),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerSection(BuildContext context, String title, EventPriority priority, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final containerColor = isDark ? Colors.grey[850] : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Center(
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 18,
                width: 80,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        ...List.generate(
          count,
          (index) => ShimmerEventCard(priority: priority),
        ),
      ],
    );
  }
}
