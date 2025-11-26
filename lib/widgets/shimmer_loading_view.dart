import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moodle_monitor/widgets/greeting_header.dart';
import 'package:moodle_monitor/widgets/shimmer_event_card.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/constants/app_strings.dart';

class ShimmerLoadingView extends StatelessWidget {
  const ShimmerLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GreetingHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 16,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          _buildShimmerSection(AppStrings.today, EventPriority.high, 2),
          _buildShimmerSection(AppStrings.tomorrow, EventPriority.medium, 2),
          _buildShimmerSection(AppStrings.next7Days, EventPriority.low, 1),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerSection(String title, EventPriority priority, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 18,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
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
