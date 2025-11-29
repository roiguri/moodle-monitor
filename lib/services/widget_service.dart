import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:moodle_monitor/models/moodle_event.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/utils/date_utils.dart';
import 'package:workmanager/workmanager.dart';

class WidgetService {
  static const String _widgetName = 'MoodleWidgetProvider';
  static const String _backgroundTaskName = 'widgetBackgroundUpdate';

  /// Initialize the widget service
  static Future<void> initialize() async {
    // Note: App Group ID is only needed for iOS
    // For Android, home_widget uses SharedPreferences automatically
    await _registerBackgroundTask();
  }

  /// Fetch data and update the widget
  static Future<void> updateWidget() async {
    try {
      final client = MoodleClient();
      final events = await client.fetchDeadlines();

      if (events.isEmpty) {
        await HomeWidget.saveWidgetData<bool>('is_empty', true);
        await HomeWidget.saveWidgetData<int>('event_count', 0);
      } else {
        // Sort events by time and take up to 10 most urgent
        events.sort((a, b) => a.timeSort.compareTo(b.timeSort));
        final upcomingEvents = events.take(10).toList();

        // Convert events to JSON format
        final eventsList = upcomingEvents.map((event) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
          final dateStr = '${dateTime.day} ${_getMonthAbbrev(dateTime.month)}';
          final priority = _getPriorityForEvent(event);

          return {
            'name': event.name,
            'course': event.course,
            'date': dateStr,
            'priority': priority,
          };
        }).toList();

        // Save as JSON string
        final eventsJson = jsonEncode(eventsList);

        await HomeWidget.saveWidgetData<bool>('is_empty', false);
        await HomeWidget.saveWidgetData<int>('event_count', upcomingEvents.length);
        await HomeWidget.saveWidgetData<String>('all_events_json', eventsJson);
      }

      // Update the widget UI
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    } catch (e) {
      // Handle error - save error state
      await HomeWidget.saveWidgetData<bool>('has_error', true);
      await HomeWidget.saveWidgetData<String>('error_message', e.toString());

      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    }
  }

  /// Get priority color based on event timing
  static String _getPriorityForEvent(MoodleEvent event) {
    final deadline = DateTime.fromMillisecondsSinceEpoch(event.timeSort * 1000);
    final priority = EventDateUtils.getPriority(deadline);

    switch (priority) {
      case EventPriority.high:
        return 'high'; // Red (Today)
      case EventPriority.medium:
        return 'medium'; // Yellow (Tomorrow)
      case EventPriority.low:
        return 'low'; // Blue (Future)
    }
  }

  /// Get month abbreviation in English
  static String _getMonthAbbrev(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Register background task for periodic widget updates
  static Future<void> _registerBackgroundTask() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic task (runs every 30 minutes)
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// Cancel background updates
  static Future<void> cancelBackgroundUpdates() async {
    await Workmanager().cancelByUniqueName(_backgroundTaskName);
  }
}

/// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await WidgetService.updateWidget();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
