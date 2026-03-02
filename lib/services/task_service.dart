import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../services/local_notification_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  // ➕ ADD TASK
  Future<void> addTask({
    required String userId,
    required String title,
    String description = '',
    DateTime? dueDate,
    String priority = 'medium',
    String relatedType = '',
    String relatedId = '',
    int reminderMinutes = 30,
  }) async {
    final doc = await _tasks.add({
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'priority': priority,
      'status': 'Open',
      'relatedType': relatedType,
      'relatedId': relatedId,
      'reminderMinutes': reminderMinutes,
      'ownerId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (dueDate != null) {
      final notifyAt =
          dueDate.subtract(Duration(minutes: reminderMinutes));

      if (notifyAt.isAfter(DateTime.now())) {
        await LocalNotificationService.scheduleTaskReminder(
          id: doc.id.hashCode,
          title: title,
          dateTime: notifyAt,
        );
      }
    }
  }

  // ✏️ UPDATE TASK
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
  try {
    await LocalNotificationService.cancel(taskId.hashCode);
  } catch (e) {}

  await _tasks.doc(taskId).update({
    'title': title,
    'description': description,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
    'priority': priority,
    'relatedType': relatedType,
    'relatedId': relatedId,
    'reminderMinutes': reminderMinutes,
  });

  if (dueDate != null) {
    final notifyAt =
        dueDate.subtract(Duration(minutes: reminderMinutes));

    if (notifyAt.isAfter(DateTime.now())) {
      await LocalNotificationService.scheduleTaskReminder(
        id: taskId.hashCode,
        title: title,
        dateTime: notifyAt,
      );
    }
  }
}


  // 🔥 TASK STREAM (FIXED)
  Stream<List<Task>> streamTasks(String userId) {
    return _tasks
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

  Future<void> markCompleted(String id) async {
  try {
    await LocalNotificationService.cancel(id.hashCode);
  } catch (e) {
    // Notification may not exist — ignore
  }

  await _tasks.doc(id).update({'status': 'Completed'});
}

Future<void> deleteTask(String id) async {
  try {
    await LocalNotificationService.cancel(id.hashCode);
  } catch (e) {
    // Notification may not exist — ignore
  }

  await _tasks.doc(id).delete();
}

}
