import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/local_notification_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  // =========================
  // ➕ ADD TASK (FIXED)
  // =========================
  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30, // ✅ NEW
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _tasks.add({
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'priority': priority,
      'status': 'Open',
      'relatedType': relatedType,
      'relatedId': relatedId,
      'reminderMinutes': reminderMinutes, // ✅ SAVE
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 🔔 SCHEDULE NOTIFICATION
    if (dueDate != null) {
      final notifyAt = dueDate.subtract(
        Duration(minutes: reminderMinutes),
      );

      if (notifyAt.isAfter(DateTime.now())) {
        await LocalNotificationService.scheduleTaskReminder(
          id: doc.id.hashCode,
          title: title,
          dateTime: notifyAt,
        );
      }
    }
  }

  // =========================
  // ✏️ UPDATE TASK (FIXED)
  // =========================
  Future<void> updateTask({
    required String taskId,
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30, // ✅ NEW
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 🔕 CANCEL OLD NOTIFICATION
    await LocalNotificationService.cancel(taskId.hashCode);

    await _tasks.doc(taskId).update({
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'priority': priority,
      'relatedType': relatedType,
      'relatedId': relatedId,
      'reminderMinutes': reminderMinutes, // ✅ UPDATE
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 🔔 RESCHEDULE NOTIFICATION
    if (dueDate != null) {
      final notifyAt = dueDate.subtract(
        Duration(minutes: reminderMinutes),
      );

      if (notifyAt.isAfter(DateTime.now())) {
        await LocalNotificationService.scheduleTaskReminder(
          id: taskId.hashCode,
          title: title,
          dateTime: notifyAt,
        );
      }
    }
  }

  // =========================
  // STREAMS (UNCHANGED)
  // =========================
  Stream<List<Task>> streamTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _tasks
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  Stream<List<Task>> streamTodayTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _tasks
        .where('ownerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Open')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  Stream<List<Task>> streamOverdueTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _tasks
        .where('ownerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Open')
        .where('dueDate', isLessThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

 // =========================
// 🔜 UPCOMING (FIXED)
// =========================
Stream<List<Task>> streamUpcomingTasks() {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  final now = DateTime.now();

  // ✅ START OF TOMORROW (00:00)
  final startOfTomorrow = DateTime(
    now.year,
    now.month,
    now.day + 1,
  );

  return _tasks
      .where('ownerId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'Open')
      .where(
        'dueDate',
        isGreaterThanOrEqualTo:
            Timestamp.fromDate(startOfTomorrow),
      )
      .snapshots()
      .map((s) {
        final list = s.docs.map(Task.fromDoc).toList();

        // Optional but recommended sorting
        list.sort((a, b) {
          final aDate = a.dueDate ?? DateTime(9999);
          final bDate = b.dueDate ?? DateTime(9999);
          return aDate.compareTo(bDate);
        });

        return list;
      });
}


  Stream<List<Task>> streamCompletedTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _tasks
        .where('ownerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  // =========================
  // ACTIONS
  // =========================
  Future<void> markCompleted(String id) async {
    await LocalNotificationService.cancel(id.hashCode);
    await _tasks.doc(id).update({'status': 'Completed'});
  }

  Future<void> deleteTask(String id) async {
    await LocalNotificationService.cancel(id.hashCode);
    await _tasks.doc(id).delete();
  }
}
