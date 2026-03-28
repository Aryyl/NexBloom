import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/assignment.dart';
import '../../data/models/subject.dart';
import '../../data/models/settings.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Request permission for Android 13+
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<bool> _areNotificationsEnabled() async {
    if (!Hive.isBoxOpen('settings')) {
      return true; // Default to true if box not open (e.g. testing)
    }
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = settingsBox.get('settings');
    return settings?.notificationsEnabled ?? true;
  }

  Future<void> scheduleAssignmentReminder(Assignment assignment) async {
    if (!await _areNotificationsEnabled()) return;
    if (assignment.deadline.isBefore(DateTime.now())) return;

    await scheduleNotification(
      id: assignment.id.hashCode,
      title: 'Assignment Due Soon',
      body:
          'Don\'t forget: ${assignment.title} is due at ${assignment.deadline.hour}:${assignment.deadline.minute}',
      scheduledDate: assignment.deadline.subtract(
        const Duration(hours: 1),
      ), // Remind 1 hour before
      channelId: 'assignment_channel',
      channelName: 'Assignment Reminders',
    );
  }

  Future<void> scheduleExamReminder(Exam exam) async {
    if (!await _areNotificationsEnabled()) return;
    if (exam.date.isBefore(DateTime.now())) return;

    await scheduleNotification(
      id: exam.id.hashCode,
      title: 'Upcoming Exam',
      body:
          'Get ready! ${exam.title} is tomorrow at ${exam.date.hour}:${exam.date.minute}',
      scheduledDate: exam.date.subtract(
        const Duration(days: 1),
      ), // Remind 1 day before
      channelId: 'exam_channel',
      channelName: 'Exam Reminders',
    );
  }

  Future<void> scheduleClassReminder(
    ClassSession session,
    String subjectName,
  ) async {
    try {
      final parts = session.startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await scheduleWeeklyClassNotification(
        id: session.id.hashCode,
        subjectName: subjectName,
        dayOfWeek: session.dayOfWeek,
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      debugPrint('Error scheduling class reminder: $e');
    }
  }

  Future<void> scheduleWeeklyClassNotification({
    required int id,
    required String subjectName,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
  }) async {
    await _scheduleWeekly(id, subjectName, dayOfWeek, hour, minute);
  }

  Future<void> _scheduleWeekly(
    int id,
    String subject,
    int day,
    int hour,
    int minute,
  ) async {
    if (!await _areNotificationsEnabled()) return;

    final scheduledDate = _nextInstanceOfDayOfWeekAndTime(day, hour, minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Class Reminder',
      'Time for $subject class!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel',
          'Class Reminders',
          channelDescription: 'Weekly class reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDayOfWeekAndTime(
    int dayOfWeek,
    int hour,
    int minute,
  ) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
    String? channelName,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId ?? 'general_channel',
          channelName ?? 'General Reminders',
          channelDescription: 'Notifications for $channelName',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general_channel',
            'General Notifications',
            channelDescription: 'General app notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
