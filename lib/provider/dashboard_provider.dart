import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  StreamSubscription? _taskSub;

  List<Task> _tasks = [];

  int customers = 0;
  int leads = 0;
  int wonLeads = 0;
  int lostLeads = 0;

  List<Task> todayTasks = [];
  List<Task> overdueTasks = [];

  bool loading = true;

  DashboardProvider() {
    _init();
  }

  void _init() {
    _taskSub = _service.allTasks().listen((tasks) {
      _tasks = tasks;
      _computeDerived();
      loading = false;
      notifyListeners();
    });

    _service.customersCount().listen((v) {
      customers = v;
      notifyListeners();
    });

    _service.leadsCount().listen((v) {
      leads = v;
      notifyListeners();
    });

    _service.leadsByStatus('Won').listen((v) {
      wonLeads = v;
      notifyListeners();
    });

    _service.leadsByStatus('Lost').listen((v) {
      lostLeads = v;
      notifyListeners();
    });
  }

  void _computeDerived() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    todayTasks = _tasks.where((t) {
      if (t.status == 'Completed') return false;
      if (t.dueDate == null) return false;
      return !t.dueDate!.isBefore(start) &&
          t.dueDate!.isBefore(end);
    }).toList();

    overdueTasks = _tasks.where((t) {
      if (t.status == 'Completed') return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isBefore(now);
    }).toList();
  }

  int get tasksCount => _tasks.length;

  int get completedTasksCount =>
      _tasks.where((t) => t.status == 'Completed').length;

  @override
  void dispose() {
    _taskSub?.cancel();
    super.dispose();
  }
}
