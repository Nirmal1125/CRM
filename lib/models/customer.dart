import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String city;
  final String orders;
  final String amountSpent;
  final DateTime createdAt;
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.city,
    required this.orders,
    required this.amountSpent,
    required this.createdAt,
  });

  factory Customer.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? '',
      city: data['city'] ?? '',
      orders: data['orders'] ?? '',
      amountSpent: data['amountSpent'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)!.toDate(),
    );
  }
}
