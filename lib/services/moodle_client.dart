import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moodle_monitor/models/moodle_event.dart';

class MoodleClient {
  final http.Client _httpClient;

  MoodleClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<List<MoodleEvent>> fetchDeadlines() async {
    final token = dotenv.env['MOODLE_TOKEN'];
    final url = dotenv.env['MOODLE_URL'];

    if (token == null || url == null) {
      throw Exception('MOODLE_TOKEN or MOODLE_URL not found in .env file');
    }

    final response = await _httpClient.get(Uri.parse(
        '$url/webservice/rest/server.php?wstoken=$token&wsfunction=core_calendar_get_action_events_by_timesort&moodlewsrestformat=json'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> events = body['events'];
      return events.map((dynamic item) => MoodleEvent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load deadlines');
    }
  }
}
