import 'dart:convert';
import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/models/moodle_course.dart';

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

  /// Validate Moodle credentials by testing the token against the API
  /// Returns true if credentials are valid, throws AuthException if invalid
  Future<bool> validateCredentials({
    required String url,
    required String token,
  }) async {
    try {
      final response = await _httpClient.get(Uri.parse(
        '$url/webservice/rest/server.php?wstoken=$token&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json',
      )).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        
        // Check for Moodle error response
        if (body is Map && body.containsKey('exception')) {
          throw AuthException('Invalid credentials: ${body['message'] ?? 'Unknown error'}');
        }
        
        // Successful validation
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException('Invalid Moodle credentials. Please check your token and URL.');
      } else {
        throw Exception('Failed to validate credentials: HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your Moodle URL.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw Exception('Failed to connect to Moodle: $e');
    }
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

  Future<List<MoodleCourse>> fetchCourses() async {
    final token = await getMoodleToken();
    final url = await getMoodleUrl();

    if (token == null || token.isEmpty || url == null || url.isEmpty) {
      throw AuthException(
        'Moodle credentials not configured. Please set your Moodle URL and Token in Settings.',
      );
    }

    // Step 1: Get the current user's ID from site info
    final siteInfoResponse = await _httpClient.get(Uri.parse(
        '$url/webservice/rest/server.php?wstoken=$token&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json'));

    if (siteInfoResponse.statusCode != 200) {
      if (siteInfoResponse.statusCode == 401 || siteInfoResponse.statusCode == 403) {
        throw AuthException('Invalid Moodle credentials. Please check your token and URL.');
      }
      throw Exception('Failed to get site info: HTTP ${siteInfoResponse.statusCode}');
    }

    final siteInfo = json.decode(siteInfoResponse.body);
    
    // Check for Moodle error response
    if (siteInfo is Map && siteInfo.containsKey('exception')) {
      throw AuthException('Invalid credentials: ${siteInfo['message'] ?? 'Unknown error'}');
    }

    final userid = siteInfo['userid'];
    if (userid == null) {
      throw Exception('Could not retrieve user ID from site info');
    }

    // Step 2: Get courses for the current user
    final response = await _httpClient.get(Uri.parse(
        '$url/webservice/rest/server.php?wstoken=$token&wsfunction=core_enrol_get_users_courses&userid=$userid&moodlewsrestformat=json'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
      // Check for Moodle error response
      if (body is Map && body.containsKey('exception')) {
        throw AuthException('Invalid credentials: ${body['message'] ?? 'Unknown error'}');
      }
      
      // Response is a list of courses
      final List<dynamic> courses = body as List<dynamic>;
      return courses.map((dynamic item) => MoodleCourse.fromJson(item, moodleUrl: url)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthException('Invalid Moodle credentials. Please check your token and URL.');
    } else {
      throw Exception('Failed to load courses: HTTP ${response.statusCode}');
    }
  }
  /// Mark an activity as complete in Moodle
  /// [cmid] is the Course Module ID
  /// [completed] true for complete, false for incomplete
  Future<bool> updateActivityCompletion(int cmid, bool completed) async {
    final token = await getMoodleToken();
    final url = await getMoodleUrl();

    if (token == null || url == null) {
      throw AuthException('Missing credentials');
    }

    // Function: core_completion_update_activity_completion_status_manually
    // Arguments: cmid, completed (1 or 0)
    final response = await _httpClient.post(
      Uri.parse('$url/webservice/rest/server.php'),
      body: {
        'wstoken': token,
        'wsfunction': 'core_completion_update_activity_completion_status_manually',
        'moodlewsrestformat': 'json',
        'cmid': cmid.toString(),
        'completed': completed ? '1' : '0',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
      // Check for exceptions
      if (body is Map && body.containsKey('exception')) {
        throw Exception(body['message']);
      }
      
      // The API returns an object like {"status": true, "warnings": []}
      return body['status'] == true;
    } else {
      throw Exception('Failed to update completion status: ${response.statusCode}');
    }
  }
}
