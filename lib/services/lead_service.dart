import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/lead.dart';

class LeadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('leads');

  // =========================
  // ➕ ADD LEAD
  // =========================
  Future<void> addLead({
    required String name,
    String company = '',
    String email = '',
    String phone = '',
    String status = 'New',
    String source = '',
    String assignedTo = '',
    String notes = '',
    int? score,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _collection.add({
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'status': status,
      'source': source,
      'assignedTo': assignedTo,
      'notes': notes,
      'score': score,
      'tags': tags,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 🔥 STABLE LEAD STREAM (WEB SAFE)
  // =========================
  Stream<List<Lead>> streamLeads() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(<Lead>[]);
      }

      return _collection
          .where('ownerId', isEqualTo: user.uid)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) => Lead.fromDoc(doc)).toList(),
          );
    });
  }

  // =========================
  // ✏️ UPDATE LEAD
  // =========================
  Future<void> updateLead(
    String id, {
    String? name,
    String? company,
    String? email,
    String? phone,
    String? status,
    String? source,
    String? assignedTo,
    String? notes,
    int? score,
    List<String>? tags,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (company != null) data['company'] = company;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (status != null) data['status'] = status;
    if (source != null) data['source'] = source;
    if (assignedTo != null) data['assignedTo'] = assignedTo;
    if (notes != null) data['notes'] = notes;
    if (score != null) data['score'] = score;
    if (tags != null) data['tags'] = tags;

    if (data.isNotEmpty) {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).update(data);
    }
  }

  // =========================
  // 🗑 DELETE LEAD
  // =========================
  Future<void> deleteLead(String id) async {
    await _collection.doc(id).delete();
  }
}
