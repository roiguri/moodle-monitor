import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/models/moodle_event.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MoodleClient moodleClient;
  late MockHttpClient mockHttpClient;
  late MockSecureStorage mockSecureStorage;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockSecureStorage = MockSecureStorage();
    moodleClient = MoodleClient(
      httpClient: mockHttpClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('MoodleClient', () {
    test('fetchDeadlines throws AuthException on 401 response', () async {
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
            final key = invocation.namedArguments[#key] as String;
            if (key == 'moodle_url') return 'https://moodle.example.com';
            if (key == 'moodle_token') return 'dummy_token';
            return null;
          });

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Unauthorized', 401),
      );

      expect(
        () => moodleClient.fetchDeadlines(),
        throwsA(isA<AuthException>()),
      );
    });

    test('fetchDeadlines throws AuthException on 403 response', () async {
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
            final key = invocation.namedArguments[#key] as String;
            if (key == 'moodle_url') return 'https://moodle.example.com';
            if (key == 'moodle_token') return 'dummy_token';
            return null;
          });

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Forbidden', 403),
      );

      expect(
        () => moodleClient.fetchDeadlines(),
        throwsA(isA<AuthException>()),
      );
    });

    test('isEventVisible returns false if course ID is hidden', () {
      final event = MoodleEvent(
        id: 1,
        name: 'Event 1',
        course: 'Course 1',
        courseid: 101,
        timeSort: 0,
        courseViewUrl: '',
        url: '',
      );
      final hiddenCourses = ['101'];
      final ignoredEvents = <String>[];

      expect(MoodleClient.isEventVisible(event, hiddenCourses, ignoredEvents), false);
    });

    test('isEventVisible returns false if event ID is ignored', () {
      final event = MoodleEvent(
        id: 1,
        name: 'Event 1',
        course: 'Course 1',
        courseid: 101,
        timeSort: 0,
        courseViewUrl: '',
        url: '',
      );
      final hiddenCourses = <String>[];
      final ignoredEvents = ['1'];

      expect(MoodleClient.isEventVisible(event, hiddenCourses, ignoredEvents), false);
    });

    test('isEventVisible returns true if neither hidden nor ignored', () {
      final event = MoodleEvent(
        id: 1,
        name: 'Event 1',
        course: 'Course 1',
        courseid: 101,
        timeSort: 0,
        courseViewUrl: '',
        url: '',
      );
      final hiddenCourses = ['102'];
      final ignoredEvents = ['2'];

      expect(MoodleClient.isEventVisible(event, hiddenCourses, ignoredEvents), true);
    });
  });
}
