import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final DateTime createdAt;
  final int? score;
  final String status;
  final List<String> tags;
  final String source;
  final String assignedTo;
  final String notes;

  Lead({
    required this.id,
    required this.name,
    required this.createdAt,
    this.company = '',
    this.email = '',
    this.phone = '',
    this.score,
    this.status = '',
    List<String>? tags,
    this.source = '',
    this.assignedTo = '',
    this.notes = '',
  }) : tags = tags ?? const [];

  // =========================
  // FROM FIRESTORE
  // =========================
  factory Lead.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Lead(
      id: doc.id,
      name: data['name'] ?? '',
      company: data['company'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      score: data['score'],
      status: data['status'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      source: data['source'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  // =========================
  // TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'score': score,
      'status': status,
      'tags': tags,
      'source': source,
      'assignedTo': assignedTo,
      'notes': notes,
    };
  }

  Lead copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    DateTime? createdAt,
    int? score,
    String? status,
    List<String>? tags,
    String? source,
    String? assignedTo,
    String? notes,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      score: score ?? this.score,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
    );
  }
}
