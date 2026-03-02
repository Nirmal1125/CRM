// lib/provider/task_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  bool _loading = true;

  StreamSubscription? _taskSub;
  StreamSubscription? _authSub;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;

  TaskProvider() {
    _authSub = _auth.authStateChanges().listen((user) {
      _taskSub?.cancel();
      _tasks = [];
      _loading = true;
      notifyListeners();

      if (user == null) {
        _loading = false;
        notifyListeners();
        return;
      }

      _taskSub = _service.streamTasks(user.uid).listen((data) {
        _tasks = data;
        _loading = false;
        notifyListeners();
      });
    });
  }

  // FILTERS
  List<Task> todayTasks() {
    final now = DateTime.now();
    return _tasks.where((t) =>
        t.status == 'Open' &&
        t.dueDate != null &&
        t.dueDate!.year == now.year &&
        t.dueDate!.month == now.month &&
        t.dueDate!.day == now.day).toList();
  }

  List<Task> overdueTasks() {
    final now = DateTime.now();
    return _tasks.where((t) =>
        t.status == 'Open' &&
        t.dueDate != null &&
        t.dueDate!.isBefore(now)).toList();
  }

  List<Task> upcomingTasks() {
    final tomorrow =
        DateTime.now().add(const Duration(days: 1));
    return _tasks.where((t) =>
        t.status == 'Open' &&
        t.dueDate != null &&
        t.dueDate!.isAfter(tomorrow)).toList();
  }

  List<Task> completedTasks() =>
      _tasks.where((t) => t.status == 'Completed').toList();

  // ACTIONS
  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _service.addTask(
      userId: user.uid,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      relatedType: relatedType,
      relatedId: relatedId,
      reminderMinutes: reminderMinutes,
    );
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30,
  }) async {
    await _service.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      relatedType: relatedType,
      relatedId: relatedId,
      reminderMinutes: reminderMinutes,
    );
  }

  Future<void> markCompleted(String id) =>
      _service.markCompleted(id);

  Future<void> deleteTask(String id) =>
      _service.deleteTask(id);

  @override
  void dispose() {
    _taskSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
