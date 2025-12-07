// lib/models/customer.dart

/// Customer data model used by the Customer list UI.
/// Make sure this file is saved as lib/models/customer.dart
class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;

  // Optional UI fields
  final String? city;
  final String? orders;
  final String? amountSpent;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    this.city,
    this.orders,
    this.amountSpent,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? status,
    String? city,
    String? orders,
    String? amountSpent,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      city: city ?? this.city,
      orders: orders ?? this.orders,
      amountSpent: amountSpent ?? this.amountSpent,
    );
  }

  /// Convenience factory for quick creation (optional)
  factory Customer.fromMap(Map m) {
    return Customer(
      id: m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      email: m['email'] ?? '',
      status: m['status'] ?? 'Lead',
      city: m['city'],
      orders: m['orders'],
      amountSpent: m['amountSpent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'city': city,
      'orders': orders,
      'amountSpent': amountSpent,
    };
  }
}
