import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<int> customersCount() {
    return _db
        .collection('customers')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> leadsCount() {
    return _db
        .collection('leads')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> leadsByStatus(String status) {
    return _db
        .collection('leads')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((s) => s.size);
  }
}
