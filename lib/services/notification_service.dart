import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:moodie/constants/app_strings.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:moodie/services/preferences_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Get device timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Check if notifications are enabled in preferences
    final prefs = await PreferencesService.getInstance();
    final shouldRequestPermissions = prefs.getNotifyNewTasks() || prefs.getNotifyDeadlines();

    if (shouldRequestPermissions) {
      await requestPermissions();
    }
  }

  /// Request notification permissions from the user
  Future<bool> requestPermissions() async {
    // Request permissions for Android 13+
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    // Request exact alarm permission (Android 12+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    return granted ?? false;
  }

  Future<void> showNewTaskNotification(String taskName, String courseName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_task_channel', // channel Id
      AppStrings.notificationChannelNewTasks, // channel Name
      channelDescription: AppStrings.notificationChannelNewTasksDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID for the notification
      AppStrings.notificationNewTaskTitle.replaceAll('{course}', courseName),
      taskName,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleDeadlineNotification(
      int id, String taskName, DateTime deadline, Duration buffer) async {
    
    final scheduledDate = deadline.subtract(buffer);
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      AppStrings.notificationDeadlineTitle,
      AppStrings.notificationDeadlineBody.replaceAll('{task}', taskName),
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          AppStrings.notificationChannelDeadlines,
          channelDescription: AppStrings.notificationChannelDeadlinesDesc,
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
