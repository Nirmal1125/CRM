import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // BASE TASK STREAM
  // =========================
  Stream<List<Task>> _allTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('tasks')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  // =========================
  // COUNTS
  // =========================
  Stream<int> customersCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _db
        .collection('customers')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> leadsCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _db
        .collection('leads')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> leadsByStatus(String status) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _db
        .collection('leads')
        .where('ownerId', isEqualTo: uid)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> tasksCount() {
    return _allTasks().map((tasks) => tasks.length);
  }

  Stream<int> completedTasksCount() {
    return _allTasks()
        .map((tasks) => tasks.where((t) => t.status == 'Completed').length);
  }

  // =========================
  // TODAY FOLLOW-UPS (FIXED)
  // =========================
  Stream<List<Task>> todayTasks() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _allTasks().map((tasks) {
      return tasks.where((t) {
        if (t.status == 'Completed') return false;
        if (t.dueDate == null) return false;

        return !t.dueDate!.isBefore(start) &&
            t.dueDate!.isBefore(end);
      }).toList();
    });
  }

  // =========================
  // OVERDUE TASKS
  // =========================
  Stream<List<Task>> overdueTasks() {
    final now = DateTime.now();

    return _allTasks().map((tasks) {
      return tasks.where((t) {
        if (t.status == 'Completed') return false;
        if (t.dueDate == null) return false;

        return t.dueDate!.isBefore(now);
      }).toList();
    });
  }
}
