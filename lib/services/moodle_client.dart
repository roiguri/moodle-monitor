import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moodle_monitor/models/moodle_event.dart';

/// Custom exception for authentication/credential errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class MoodleClient {
  static const String _keyMoodleUrl = 'moodle_url';
  static const String _keyMoodleToken = 'moodle_token';

  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  MoodleClient({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Get Moodle URL from secure storage
  Future<String?> getMoodleUrl() async {
    final url = await _secureStorage.read(key: _keyMoodleUrl);
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Get Moodle Token from secure storage
  Future<String?> getMoodleToken() async {
    final token = await _secureStorage.read(key: _keyMoodleToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Save Moodle credentials to secure storage
  Future<void> saveCredentials({
    required String url,
    required String token,
  }) async {
    await _secureStorage.write(key: _keyMoodleUrl, value: url);
    await _secureStorage.write(key: _keyMoodleToken, value: token);
  }

  /// Check if credentials are configured
  Future<bool> hasCredentials() async {
    final url = await getMoodleUrl();
    final token = await getMoodleToken();
    return url != null && url.isNotEmpty && token != null && token.isNotEmpty;
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyMoodleUrl);
    await _secureStorage.delete(key: _keyMoodleToken);
  }

  Future<List<MoodleEvent>> fetchDeadlines() async {
    final token = await getMoodleToken();
    final url = await getMoodleUrl();

    if (token == null || token.isEmpty || url == null || url.isEmpty) {
      throw AuthException(
        'Moodle credentials not configured. Please set your Moodle URL and Token in Settings.',
      );
    }

    final response = await _httpClient.get(Uri.parse(
        '$url/webservice/rest/server.php?wstoken=$token&wsfunction=core_calendar_get_action_events_by_timesort&moodlewsrestformat=json'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
      // Check for Moodle error response (e.g., invalid token)
      if (body is Map && body.containsKey('exception')) {
        throw AuthException('Invalid credentials: ${body['message'] ?? 'Unknown error'}');
      }
      
      final List<dynamic> events = body['events'];
      return events.map((dynamic item) => MoodleEvent.fromJson(item)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Unauthorized or Forbidden - invalid credentials
      throw AuthException('Invalid Moodle credentials. Please check your token and URL.');
    } else {
      throw Exception('Failed to load deadlines: HTTP ${response.statusCode}');
    }
  }
}
