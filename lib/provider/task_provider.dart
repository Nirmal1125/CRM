import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  bool _loading = true;
  StreamSubscription? _sub;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;

  TaskProvider() {
    _sub = _service.streamTasks().listen((data) {
      _tasks = data;
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================= FILTERS =================

  List<Task> todayTasks() {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null || t.status != 'Open') return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> overdueTasks() {
    final now = DateTime.now();
    return _tasks.where((t) {
      return t.status == 'Open' &&
          t.dueDate != null &&
          t.dueDate!.isBefore(now);
    }).toList();
  }

  List<Task> upcomingTasks() {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1);
    return _tasks.where((t) {
      return t.status == 'Open' &&
          t.dueDate != null &&
          t.dueDate!.isAfter(tomorrow);
    }).toList();
  }

  List<Task> completedTasks() {
    return _tasks.where((t) => t.status == 'Completed').toList();
  }

  // ================= ACTIONS (OPTIMISTIC) =================

  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30,
  }) async {
    await _service.addTask(
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

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
  }

  Future<void> markCompleted(String id) async {
    await _service.markCompleted(id);
  }
}
