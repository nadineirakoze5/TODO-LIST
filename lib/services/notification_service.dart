import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/db/database_helper.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Schedule notification 10 minutes before task
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime taskDateTime,
  }) async {
    final scheduledTime = taskDateTime.subtract(const Duration(minutes: 10));
    if (scheduledTime.isBefore(DateTime.now())) return; // prevent past notif

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel_id',
          'Task Notifications',
          channelDescription: 'Reminder for upcoming tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // daily optional
    );
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 🔁 Reschedule all notifications from SQLite
  static Future<void> rescheduleFromSQLite() async {
    await cancelAll();
    final tasks = await DatabaseHelper.instance.getTasks();
    for (var task in tasks) {
      final dt = DateTime.tryParse(task.date);
      final timeParts = task.time.split(':');
      if (dt != null) {
        final taskDateTime = DateTime(
          dt.year,
          dt.month,
          dt.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        if (task.isDone == 0) {
          await scheduleNotification(
            id: task.localId ?? task.hashCode,
            title: "Upcoming Task",
            body: task.title,
            taskDateTime: taskDateTime,
          );
        }
      }
    }
  }

  /// 🔁 Reschedule all notifications from Firestore
  static Future<void> rescheduleFromFirestore() async {
    await cancelAll();
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final task = TaskModel.fromMap({...data, 'id': doc.id});

      final dt = DateTime.tryParse(task.date);
      final timeParts = task.time.split(':');

      if (dt != null) {
        final taskDateTime = DateTime(
          dt.year,
          dt.month,
          dt.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        if (task.isDone == 0) {
          await scheduleNotification(
            id: task.hashCode, // Firestore task ID is String; use hashCode
            title: "Upcoming Task",
            body: task.title,
            taskDateTime: taskDateTime,
          );
        }
      }
    }
  }
}
