import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../services/lead_service.dart';

class LeadProvider extends ChangeNotifier {
  final LeadService _service = LeadService();

  List<Lead> _leads = [];
  bool _loading = true;
  StreamSubscription? _sub;

  List<Lead> get leads => _leads;
  bool get loading => _loading;

  LeadProvider() {
    _sub = _service.streamLeads().listen((data) {
      _leads = data;
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================= FILTER HELPERS =================

  List<Lead> filtered({
    required String query,
    required String status,
  }) {
    return _leads.where((l) {
      final statusOk =
          status == 'All' || l.status.toLowerCase() == status.toLowerCase();

      final q = query.toLowerCase();
      final queryOk = q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.email.toLowerCase().contains(q) ||
          l.phone.toLowerCase().contains(q);

      return statusOk && queryOk;
    }).toList();
  }

  // ================= ACTIONS =================

  Future<void> addLead(Map<String, dynamic> data) async {
    await _service.addLead(
      name: data['name'],
      company: data['company'],
      email: data['email'],
      phone: data['phone'],
      status: data['status'],
      source: data['source'],
      assignedTo: data['assignedTo'],
      notes: data['notes'],
      tags: data['tags'],
      score: data['score'],
    );
  }

  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    await _service.updateLead(
      id,
      name: data['name'],
      company: data['company'],
      email: data['email'],
      phone: data['phone'],
      status: data['status'],
      source: data['source'],
      assignedTo: data['assignedTo'],
      notes: data['notes'],
      tags: data['tags'],
      score: data['score'],
    );
  }

  Future<void> deleteLead(String id) async {
    await _service.deleteLead(id);
  }

  Future<void> convertLead(Lead lead) async {
    await _service.convertLeadToCustomer(lead);
  }
}
