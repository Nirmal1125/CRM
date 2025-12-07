import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance.collection('customers');

  static Future<void> addCustomer(Customer customer) async {
    await _db.add(customer.toMap());
  }

  static Future<void> updateCustomer(Customer customer) async {
    await _db.doc(customer.id).update(customer.toMap());
  }

  static Future<void> deleteCustomer(String id) async {
    await _db.doc(id).delete();
  }

  // Fetch methods for A (e.g., Stream<List<Customer>> getCustomers() { ... })
}
