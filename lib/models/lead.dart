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

// lib/models/lead.dart
// Unified Lead model used across services/screens/widgets.

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

  // Additional fields referenced by your code
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
  }) : tags = tags ?? <String>[];

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

  factory Lead.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['createdAt'] is DateTime) {
      parsedDate = json['createdAt'] as DateTime;
    } else {
      parsedDate = DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
    }

    final dynamic tagsRaw = json['tags'];
    List<String> parsedTags = <String>[];
    try {
      if (tagsRaw is List) {
        parsedTags = tagsRaw.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).cast<String>().toList();
      } else if (tagsRaw is String && tagsRaw.isNotEmpty) {
        parsedTags = tagsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {
      parsedTags = <String>[];
    }

    return Lead(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      createdAt: parsedDate,
      score: json['score'] != null ? int.tryParse(json['score'].toString()) : null,
      status: json['status']?.toString() ?? '',
      tags: parsedTags,
      source: json['source']?.toString() ?? '',
      assignedTo: json['assignedTo']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'score': score,
      'status': status,
      'tags': tags,
      'source': source,
      'assignedTo': assignedTo,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Lead(id: $id, name: $name, company: $company, status: $status, score: $score)';
  }
}
