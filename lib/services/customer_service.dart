import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/customer.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('customers');

  // =========================
  // ➕ ADD CUSTOMER
  // =========================
  Future<void> addCustomer({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String status,
    required String city,
    required String orders,
    required String amountSpent,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _collection.add({
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'status': status,
      'city': city,
      'orders': orders,
      'amountSpent': amountSpent,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 🔥 STABLE CUSTOMER STREAM (WEB SAFE)
  // =========================
  Stream<List<Customer>> streamCustomers() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(<Customer>[]);
      }

      return _collection
          .where('ownerId', isEqualTo: user.uid)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((d) => Customer.fromDoc(d)).toList(),
          );
    });
  }

  // =========================
  // ✏️ UPDATE CUSTOMER
  // =========================
  Future<void> updateCustomer(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String company,
    required String status,
    required String city,
    required String orders,
    required String amountSpent,
  }) async {
    await _collection.doc(id).update({
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'status': status,
      'city': city,
      'orders': orders,
      'amountSpent': amountSpent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 🗑 DELETE CUSTOMER
  // =========================
  Future<void> deleteCustomer(String id) async {
    await _collection.doc(id).delete();
  }
}
