import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String status;
  final String relatedType;
  final String relatedId;
  final String ownerId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.status = 'Open',
    this.relatedType = '',
    this.relatedId = '',
    this.ownerId = '',
  });

  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'Open',
      relatedType: data['relatedType'] ?? '',
      relatedId: data['relatedId'] ?? '',
      ownerId: data['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null
          ? Timestamp.fromDate(dueDate!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'relatedType': relatedType,
      'relatedId': relatedId,
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
