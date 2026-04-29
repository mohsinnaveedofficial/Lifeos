import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Changed channel ID to ensure new settings (importance/priority) take effect
  static const AndroidNotificationChannel _taskReminderChannel =
      AndroidNotificationChannel(
    'task_deadline_channel_v2', 
    'Task Deadlines',
    description: 'Notifications for task deadlines',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  NotificationDetails _reminderDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _taskReminderChannel.id,
        _taskReminderChannel.name,
        channelDescription: _taskReminderChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ticker: 'Task Reminder',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Note: We don't set local location here to avoid dependency on extra plugins.
    // We will use UTC for scheduling to ensure absolute time accuracy.

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    // Request basic notification permission (Android 13+)
    await androidPlugin?.requestNotificationsPermission();
    
    // Create the channel
    await androidPlugin?.createNotificationChannel(_taskReminderChannel);

    final iOSPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iOSPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    // Handle notification tap
  }

  /// Schedule a task reminder notification for the given deadline
  Future<int> scheduleTaskReminder({
    required String taskName,
    required DateTime deadline,
    required String taskId,
    int minutesBefore = 0,
  }) async {
    final notificationId = taskId.hashCode.abs() % 2147483647;

    try {
      final now = DateTime.now();
      final remindTime = deadline.subtract(Duration(minutes: minutesBefore));

      // As per user request: only show at deadline, not at creation.
      // If deadline is in the past, we don't schedule anything.
      if (remindTime.isBefore(now)) {
        return notificationId;
      }

      // We use UTC for scheduling to be 100% sure about the absolute time point.
      // This avoids issues with uninitialized tz.local or timezone shifts.
      final scheduledDate = tz.TZDateTime.from(remindTime.toUtc(), tz.UTC);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder',
        minutesBefore == 0 
            ? 'Task "$taskName" is due now!'
            : 'Task "$taskName" is due in $minutesBefore minutes',
        scheduledDate,
        _reminderDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Inexact mode avoids the need for the "Alarms and reminders" system toggle
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      return notificationId;
    } catch (e) {
      print('Error scheduling task reminder: $e');
      return notificationId;
    }
  }

  Future<void> cancelReminder(String taskId) async {
    try {
      final notificationId = taskId.hashCode.abs() % 2147483647;
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      print('Error canceling reminder: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  Future<void> showTaskCompletedNotification(String taskName) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Task Completed',
        'Great job! You completed "$taskName"',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_completed_channel',
            'Task Completions',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      print('Error showing task completed notification: $e');
    }
  }
}
