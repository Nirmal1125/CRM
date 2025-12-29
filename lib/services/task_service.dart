import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'package:rxdart/rxdart.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  // ➕ ADD TASK
  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    String relatedType = '',
    String relatedId = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _tasks.add({
      'title': title,
      'description': description,
      'dueDate': dueDate != null
          ? Timestamp.fromDate(dueDate)
          : null,
      'status': 'Open',
      'relatedType': relatedType,
      'relatedId': relatedId,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 STREAM TASKS
  Stream<List<Task>> streamTasks() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value([]);

      return _tasks
          .where('ownerId', isEqualTo: user.uid)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => Task.fromDoc(d)).toList());
    });
  }

  // ✔ COMPLETE TASK
  Future<void> markCompleted(String id) async {
    await _tasks.doc(id).update({
      'status': 'Completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✏️ UPDATE TASK
Future<void> updateTask({
  required String taskId,
  required String title,
  String description = '',
  DateTime? dueDate,
}) async {
  await _tasks.doc(taskId).update({
    'title': title,
    'description': description,
    'dueDate':
        dueDate != null ? Timestamp.fromDate(dueDate) : null,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}


  // 🗑 DELETE TASK
  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
