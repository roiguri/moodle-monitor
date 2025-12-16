import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moodie/models/app_event.dart';
import 'package:moodie/models/moodle_event.dart';
import 'package:moodie/models/custom_event.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/services/database_service.dart';
import 'package:moodie/utils/date_utils.dart';
import 'package:workmanager/workmanager.dart';
import 'package:moodie/services/notification_service.dart';
import 'package:moodie/services/cache_service.dart';
import 'package:moodie/services/preferences_service.dart';
import 'package:moodie/constants/app_strings.dart';

// 1. Top-level function (Outside any class)
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'refresh_click') {
    await WidgetService.updateWidget();
  }
}

class WidgetService {
  static const String _widgetName = 'MoodleWidgetProvider';
  static const String _backgroundTaskName = 'widgetBackgroundUpdate';

  /// Initialize the widget service
  static Future<void> initialize() async {
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
    await _registerBackgroundTask();
  }

  /// Fetch data and update the widget
  static Future<void> updateWidget() async {
    try {
      // 1. Fetch Data
      final client = MoodleClient();
      final db = DatabaseService();

      final List<AppEvent> allEvents = [];

      // Moodle
      try {
        final moodleEvents = await client.fetchVisibleDeadlines();
        allEvents.addAll(moodleEvents);
      } catch (e) {
        print('Widget fetch moodle error: $e');
      }

      // Custom
      try {
        final now = DateTime.now();
        final customEvents = await db.getEventsForRange(now, now.add(const Duration(days: 365)));
        allEvents.addAll(customEvents);
      } catch (e) {
        print('Widget fetch custom error: $e');
      }

      // 2. Prepare Widget Data (Deadlines Only)
      final widgetEvents = allEvents.where((e) =>
        e.type == AppEventType.moodleDeadline || e.type == AppEventType.customDeadline
      ).toList();

      if (widgetEvents.isEmpty) {
        await HomeWidget.saveWidgetData<bool>('is_empty', true);
        await HomeWidget.saveWidgetData<int>('event_count', 0);
      } else {
        widgetEvents.sort((a, b) => a.date.compareTo(b.date));
        final upcomingEvents = widgetEvents.take(10).toList();

        final eventsList = upcomingEvents.map((event) {
          final dateTime = event.date;
          final dateStr = _formatDate(dateTime);
          final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          final priority = _getPriorityForEvent(event);

          return {
            'name': event.title,
            'course': event.courseName, // Can be empty for custom
            'date': dateStr,
            'time': timeStr,
            'priority': priority,
          };
        }).toList();

        final eventsJson = jsonEncode(eventsList);

        await HomeWidget.saveWidgetData<bool>('is_empty', false);
        await HomeWidget.saveWidgetData<int>('event_count', upcomingEvents.length);
        await HomeWidget.saveWidgetData<String>('all_events_json', eventsJson);
      }

      // 3. Notification Logic
      await _handleNotifications(allEvents);

      // 4. Update UI
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    } catch (e) {
      await HomeWidget.saveWidgetData<bool>('has_error', true);
      await HomeWidget.saveWidgetData<String>('error_message', e.toString());

      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    }
  }

  static Future<void> _handleNotifications(List<AppEvent> allEvents) async {
    final cacheService = CacheService();
    final notificationService = NotificationService();
    final prefs = await PreferencesService.getInstance();

    final notifyNewTasks = prefs.getNotifyNewTasks();
    final notifyDeadlines = prefs.getNotifyDeadlines();
    final notifyCustomTasks = prefs.getNotifyCustomTasks();

    final knownIds = await cacheService.getKnownTaskIds();
    final isFirstFetchCompleted = prefs.getIsFirstFetchCompleted();

    // Check for NEW tasks (Moodle Only)
    // We skip Custom events for "New Task" notification as user created them.
    if (notifyNewTasks && isFirstFetchCompleted) {
      for (final event in allEvents) {
        if (event.type == AppEventType.moodleDeadline) {
          if (!knownIds.contains(event.uniqueId)) {
            await notificationService.showNewTaskNotification(
              event.title,
              event.courseName,
            );
          }
        }
      }
    }

    // Sync cache
    final currentTaskIds = allEvents.map((e) => e.uniqueId).toList();
    await cacheService.saveTaskIds(currentTaskIds);

    if (!isFirstFetchCompleted) {
      await prefs.setIsFirstFetchCompleted(true);
    }

    // Schedule Reminders
    final alertOffsets = prefs.getDeadlineAlerts();

    for (final event in allEvents) {
      // Check prefs based on type
      bool shouldNotify = false;
      if (event.type == AppEventType.customTask) {
        if (notifyCustomTasks) shouldNotify = true;
      } else {
        // Deadlines (Moodle + Custom)
        if (notifyDeadlines) shouldNotify = true;
      }

      if (shouldNotify) {
        final deadline = event.date;
        for (final offsetMinutes in alertOffsets) {
          // Unique ID generation using hashCode to handle string IDs
          // Combining with offset to make it unique per alert time
          final notificationId = (event.uniqueId.hashCode) + offsetMinutes;

          await notificationService.scheduleDeadlineNotification(
            notificationId,
            event.title,
            deadline,
            Duration(minutes: offsetMinutes),
          );
        }
      }
    }
  }

  static String _getPriorityForEvent(AppEvent event) {
    final deadline = event.date;
    final priority = EventDateUtils.getPriority(deadline);

    switch (priority) {
      case EventPriority.high:
        return 'high';
      case EventPriority.medium:
        return 'medium';
      case EventPriority.low:
        return 'low';
    }
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck.isAtSameMomentAs(today)) {
      return AppStrings.today;
    } else if (dateToCheck.isAtSameMomentAs(tomorrow)) {
      return AppStrings.tomorrow;
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
  }

  static Future<void> _registerBackgroundTask() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelBackgroundUpdates() async {
    await Workmanager().cancelByUniqueName(_backgroundTaskName);
  }
}

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
