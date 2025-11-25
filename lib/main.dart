import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodle Monitor',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodle Deadlines'),
      ),
      body: FutureBuilder<List<MoodleEvent>>(
        future: _deadlines,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
                final formattedDeadline = DateFormat('E, d MMM yyyy HH:mm').format(deadline);

                return ListTile(
                  isThreeLine: true,
                  title: Text(event.name),
                  subtitle: Text('${event.course}\n$formattedDeadline'),
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
