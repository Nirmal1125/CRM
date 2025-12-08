// lib/services/leads_service.dart
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/lead.dart';

class LeadsService {
  // Singleton in-memory service
  static final LeadsService _instance = LeadsService._internal();
  factory LeadsService() => _instance;
  LeadsService._internal() {
    _leads = [
      Lead(
        id: _uuid.v4(),
        name: 'Priya Sharma',
        company: 'Acme Corp',
        email: 'priya@acme.com',
        phone: '+91 98765 43210',
        source: 'Website',
        status: 'New',
        assignedTo: 'Anandhu',
        notes: 'Interested in demo',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Lead(
        id: _uuid.v4(),
        name: 'Rahul Verma',
        company: 'Beta Ltd.',
        email: 'rahul@beta.com',
        phone: '+91 91234 56789',
        source: 'Referral',
        status: 'Contacted',
        assignedTo: 'Bala',
        notes: 'Follow up next week',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Lead(
        id: _uuid.v4(),
        name: 'Sana Iqbal',
        company: 'Gamma LLC',
        email: 'sana@gamma.com',
        phone: '+91 99887 77665',
        source: 'Event',
        status: 'Qualified',
        assignedTo: 'Anandhu',
        notes: 'Budget confirmed',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  final _uuid = const Uuid();
  late List<Lead> _leads;

  // mimic network delay
  Future<List<Lead>> getLeads({String query = '', String status = 'All'}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<Lead> copy = List.from(_leads);
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      copy = copy.where((l) {
        final name = (l.name).toLowerCase();
        final company = (l.company).toLowerCase();
        final email = (l.email).toLowerCase();
        final phone = (l.phone).toLowerCase();
        return name.contains(q) || company.contains(q) || email.contains(q) || phone.contains(q);
      }).toList();
    }
    if (status != 'All') copy = copy.where((l) => l.status == status).toList();
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  Future<Lead> createLead(Lead lead) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final created = Lead(
      id: _uuid.v4(),
      name: lead.name,
      company: lead.company,
      email: lead.email,
      phone: lead.phone,
      source: lead.source,
      status: lead.status,
      assignedTo: lead.assignedTo,
      notes: lead.notes,
      createdAt: DateTime.now(),
      score: lead.score,
      tags: lead.tags,
    );
    _leads.insert(0, created);
    return created;
  }

  Future<Lead> updateLead(String id, Lead updated) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _leads.indexWhere((l) => l.id == id);
    if (idx == -1) throw Exception('Lead not found');
    final merged = _leads[idx].copyWith(
      name: updated.name,
      company: updated.company,
      email: updated.email,
      phone: updated.phone,
      source: updated.source,
      status: updated.status,
      assignedTo: updated.assignedTo,
      notes: updated.notes,
      score: updated.score,
      tags: updated.tags,
      // keep existing createdAt if not provided
      createdAt: updated.createdAt != _leads[idx].createdAt ? updated.createdAt : _leads[idx].createdAt,
    );
    _leads[idx] = merged;
    return merged;
  }

  Future<void> deleteLead(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _leads.removeWhere((l) => l.id == id);
  }
}
