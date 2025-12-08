// lib/services/lead_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/lead.dart';

class LeadService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('leads');

  String _requireUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  Future<void> addLead({
    required String title,
    required String status,
    required String source,
    required String customerId,
    double? value,
  }) async {
    final uid = _requireUid();

    await _collection.add({
      'title': title,
      'status': status,
      'source': source,
      'customerId': customerId,
      'value': value,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLead(
    String id, {
    required String title,
    required String status,
    required String source,
    required String customerId,
    double? value,
  }) async {
    _requireUid();
    await _collection.doc(id).update({
      'title': title,
      'status': status,
      'source': source,
      'customerId': customerId,
      'value': value,
    });
  }

  Stream<List<Lead>> streamLeads() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Lead>>.empty();
    }

    return _collection
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map(
                (doc) =>
                    Lead.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>),
              )
              .toList();
        });
  }

  Future<void> deleteLead(String id) async {
    _requireUid();
    await _collection.doc(id).delete();
  }
}
