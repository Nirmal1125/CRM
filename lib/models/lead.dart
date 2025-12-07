// lib/models/lead.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  final String id;
  final String title;
  final String status; // e.g. "New", "In Progress", "Won", "Lost"
  final String source; // e.g. "Website", "Call", "Referral"
  final String customerId; // optional: link to a customer
  final double? value; // deal value
  final DateTime createdAt;
  final String ownerId;

  Lead({
    required this.id,
    required this.title,
    required this.status,
    required this.source,
    required this.customerId,
    required this.value,
    required this.createdAt,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'source': source,
      'customerId': customerId,
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
    };
  }

  factory Lead.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];

    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    } else {
      created = DateTime.now();
    }

    return Lead(
      id: doc.id,
      title: data['title'] ?? '',
      status: data['status'] ?? 'New',
      source: data['source'] ?? '',
      customerId: data['customerId'] ?? '',
      value: (data['value'] is num) ? (data['value'] as num).toDouble() : null,
      createdAt: created,
      ownerId: data['ownerId'] ?? '',
    );
  }
}
