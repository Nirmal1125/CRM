import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';

class CustomerService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('customers')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? {},
        toFirestore: (data, _) => data,
      );

  String _requireUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  Future<void> addCustomer({
    required String name,
    required String email,
    required String phone,
    required String company,
  }) async {
    final uid = _requireUid();

    await _collection.add({
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Customer>> streamCustomers() {
    final user = _auth.currentUser;
    if (user == null) {
      // if not logged in, just return an empty list instead of crashing
      return const Stream<List<Customer>>.empty();
    }

    return _collection
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            return Customer.fromDoc(doc);
          }).toList();
        });
  }

  Future<void> updateCustomer(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String company,
  }) async {
    _requireUid(); // just to ensure logged in
    await _collection.doc(id).update({
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
    });
  }

  Future<void> deleteCustomer(String id) async {
    _requireUid();
    await _collection.doc(id).delete();
  }
}
