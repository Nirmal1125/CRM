// lib/provider/dashboard_provider.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_provider.dart';
import 'lead_provider.dart';
import 'customer_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final TaskProvider taskProvider;
  final LeadProvider leadProvider;
  final CustomerProvider customerProvider;

  DashboardProvider({
    required this.taskProvider,
    required this.leadProvider,
    required this.customerProvider,
  }) {
    taskProvider.addListener(_recompute);
    leadProvider.addListener(_recompute);
    customerProvider.addListener(_recompute);
    _recompute();
  }

  // ================= COUNTS =================
  int customers = 0;
  int leads = 0;
  int wonLeads = 0;
  int lostLeads = 0;

  // ================= TASKS =================
  int tasksCount = 0;
  int completedTasksCount = 0;

  List<Task> todayTasks = [];
  List<Task> overdueTasks = [];

  void _recompute() {
    final tasks = taskProvider.tasks;
    final leadsList = leadProvider.leads;
    final customersList = customerProvider.customers;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    // TASK COUNTS
    tasksCount = tasks.length;
    completedTasksCount =
        tasks.where((t) => t.status == 'Completed').length;

    todayTasks = tasks.where((t) {
      if (t.status == 'Completed' || t.dueDate == null) return false;
      return !t.dueDate!.isBefore(start) &&
          t.dueDate!.isBefore(end);
    }).toList();

    overdueTasks = tasks.where((t) {
      if (t.status == 'Completed' || t.dueDate == null) return false;
      return t.dueDate!.isBefore(now);
    }).toList();

    // LEAD COUNTS
    leads = leadsList.length;
    wonLeads =
        leadsList.where((l) => l.status == 'Won').length;
    lostLeads =
        leadsList.where((l) => l.status == 'Lost').length;

    // CUSTOMER COUNT
    customers = customersList.length;

    notifyListeners();
  }

  @override
  void dispose() {
    taskProvider.removeListener(_recompute);
    leadProvider.removeListener(_recompute);
    customerProvider.removeListener(_recompute);
    super.dispose();
  }
}
