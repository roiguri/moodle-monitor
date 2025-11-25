import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('he_IL', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodle Monitor',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew, Israel
        Locale('en', 'US'), // English, United States
      ],
      locale: const Locale('he', 'IL'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final MoodleClient _moodleClient;
  late Future<List<MoodleEvent>> _deadlines;

  @override
  void initState() {
    super.initState();
    _moodleClient = MoodleClient();
    _deadlines = _moodleClient.fetchDeadlines();
  }

  Map<String, List<MoodleEvent>> _groupEvents(List<MoodleEvent> events) {
    final Map<String, List<MoodleEvent>> groupedEvents = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final event in events) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
      final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

      String dayKey;
      if (deadlineDay.isAtSameMomentAs(today)) {
        dayKey = 'היום';
      } else if (deadlineDay.isAtSameMomentAs(tomorrow)) {
        dayKey = 'מחר';
      } else {
        dayKey = DateFormat.yMMMMd('he_IL').format(deadline);
      }

      if (groupedEvents.containsKey(dayKey)) {
        groupedEvents[dayKey]!.add(event);
      } else {
        groupedEvents[dayKey] = [event];
      }
    }
    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מטלות והגשות'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MoodleEvent>>(
        future: _deadlines,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final groupedEvents = _groupEvents(snapshot.data!);
            final dayKeys = groupedEvents.keys.toList();

            // Ensure Today and Tomorrow are first if they exist
            if (dayKeys.contains('מחר')) {
              dayKeys.remove('מחר');
              dayKeys.insert(0, 'מחר');
            }
            if (dayKeys.contains('היום')) {
              dayKeys.remove('היום');
              dayKeys.insert(0, 'היום');
            }

            return ListView.builder(
              itemCount: dayKeys.length,
              itemBuilder: (context, index) {
                final dayKey = dayKeys[index];
                final events = groupedEvents[dayKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        dayKey,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (events.isNotEmpty)
                      ...events.map((event) {
                        final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
                        final formattedTime = DateFormat.Hm('he_IL').format(deadline);
                        return ListTile(
                          isThreeLine: true,
                          title: Text(event.name),
                          subtitle: Text('${event.course}\n$formattedTime'),
                        );
                      })
                    else
                      const ListTile(
                        title: Text('אין מטלות להגשה'),
                      ),
                    const Divider(),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
