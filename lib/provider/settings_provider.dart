import 'package:flutter/material.dart';
import '../services/local_notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool pushNotifications = true;
  bool taskReminders = true;
  bool darkMode = false;

  // ================= PUSH NOTIFICATIONS =================
  void togglePushNotifications(bool value) {
    pushNotifications = value;

    // 🔕 Turn OFF all notifications immediately
    if (!value) {
      LocalNotificationService.cancelAll();
    }

    notifyListeners();
  }

  // ================= TASK REMINDERS =================
  void toggleTaskReminders(bool value) {
    taskReminders = value;

    // 🔕 Cancel reminder notifications when turned off
    if (!value) {
      LocalNotificationService.cancelAll();
    }

    notifyListeners();
  }

  // ================= DARK MODE =================
  void toggleDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }
}
