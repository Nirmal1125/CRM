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

  // 🔔 REMINDER
  final int reminderMinutes;

  // 🕒 CREATED TIME (NEW)
  final DateTime? createdAt;

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
    this.reminderMinutes = 30,
    this.createdAt,
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
      reminderMinutes: data['reminderMinutes'] ?? 30,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? relatedType,
    String? relatedId,
    int? reminderMinutes,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      relatedType: relatedType ?? this.relatedType,
      relatedId: relatedId ?? this.relatedId,
      ownerId: ownerId,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt,
    );
  }
}
