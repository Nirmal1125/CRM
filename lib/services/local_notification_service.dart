import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Task Reminders';
  static const String _channelDesc = 'Task due reminders';

  // ================= INIT =================

  static Future<void> init() async {
    // ✅ Required for zonedSchedule
    tzData.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      );

      await androidPlugin.createNotificationChannel(channel);

      // ✅ ONLY notification permission (NOT exact alarm)
      await androidPlugin.requestNotificationsPermission();
    }
  }

  // ================= SCHEDULE =================

  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('⚠️ Skipped past notification');
      }
      return;
    }

    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        'Task Reminder',
        title,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,

        // 🚫 DO NOT request exact alarm behavior
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Notification scheduling failed: $e');
      }
    }
  }

  // ================= CANCEL =================

  static Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
