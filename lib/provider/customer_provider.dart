import 'dart:async';
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service = CustomerService();

  List<Customer> _customers = [];
  bool _loading = true;
  StreamSubscription? _sub;

  List<Customer> get customers => _customers;
  bool get loading => _loading;

  CustomerProvider() {
    _sub = _service.streamCustomers().listen((data) {
      _customers = data;
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================= ACTIONS =================

  Future<void> addCustomer(Map<String, dynamic> data) async {
    await _service.addCustomer(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      company: data['company'],
      status: data['status'],
      city: data['city'],
      orders: data['orders'],
      amountSpent: data['amountSpent'],
    );
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    await _service.updateCustomer(
      id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      company: data['company'],
      status: data['status'],
      city: data['city'],
      orders: data['orders'],
      amountSpent: data['amountSpent'],
    );
  }

  Future<void> deleteCustomer(String id) async {
    await _service.deleteCustomer(id);
  }
}
