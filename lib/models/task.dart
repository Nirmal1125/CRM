import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String status;
  final String priority;
  final String relatedType;
  final String relatedId;
  final String ownerId;

  // 🔔 REMINDER (NEW – REQUIRED FOR EDIT REMINDER TIME)
  final int reminderMinutes;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.status = 'Open',
    this.priority = 'medium',
    this.relatedType = '',
    this.relatedId = '',
    this.ownerId = '',
    this.reminderMinutes = 30, // ✅ DEFAULT (SAFE FOR OLD TASKS)
  });

  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'Open',
      priority: data['priority'] ?? 'medium',
      relatedType: data['relatedType'] ?? '',
      relatedId: data['relatedId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      reminderMinutes: data['reminderMinutes'] ?? 30, // ✅ NEW
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status,
      'priority': priority,
      'relatedType': relatedType,
      'relatedId': relatedId,
      'ownerId': ownerId,
      'reminderMinutes': reminderMinutes, // ✅ NEW
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
