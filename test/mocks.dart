import 'package:mocktail/mocktail.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/models/moodle_event.dart';

class MockMoodleClient extends Mock implements MoodleClient {}
class MockMoodleEvent extends Mock implements MoodleEvent {}
