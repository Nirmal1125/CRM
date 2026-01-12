import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Task>> allTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('tasks')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((s) => s.docs.map(Task.fromDoc).toList());
  }

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
}
