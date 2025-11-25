import 'package:flutter/material.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/widgets/greeting_header.dart';
import 'package:moodle_monitor/widgets/summary_text.dart';
import 'package:moodle_monitor/widgets/event_card.dart';
import 'package:moodle_monitor/widgets/event_section.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:moodle_monitor/constants/app_strings.dart';
import 'package:moodle_monitor/constants/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodleClient _moodleClient;
  late Future<List<MoodleEvent>> _deadlines;

  @override
  void initState() {
    super.initState();
    _moodleClient = MoodleClient();
    _deadlines = _moodleClient.fetchDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<MoodleEvent>>(
          future: _deadlines,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final events = snapshot.data!;
              final groupedEvents = EventDateUtils.groupEventsByDate(events);
              final dayKeys = EventDateUtils.getSortedDayKeys(groupedEvents);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingHeader(),
                    SummaryText(allEvents: events),

                    // Display all sections in order
                    ...dayKeys.map((dayKey) {
                      final sectionEvents = groupedEvents[dayKey]!;
                      EventPriority priority;

                      // Determine priority based on section
                      if (dayKey == AppStrings.today) {
                        priority = EventPriority.high;
                      } else if (dayKey == AppStrings.tomorrow) {
                        priority = EventPriority.medium;
                      } else {
                        priority = EventPriority.low;
                      }

                      return EventSection(
                        title: dayKey,
                        events: sectionEvents,
                        priority: priority,
                      );
                    }),

                    // Empty state
                    if (dayKeys.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppStrings.noTasks,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
