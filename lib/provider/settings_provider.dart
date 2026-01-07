import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool pushNotifications = true;
  bool taskReminders = true;
  bool darkMode = false;

  void togglePushNotifications(bool value) {
    pushNotifications = value;
    notifyListeners();
  }

  void toggleTaskReminders(bool value) {
    taskReminders = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }
}
