import 'dart:async';
import 'package:crm/screen/add_lead_screen.dart';
import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../services/lead_service.dart';
import '../widgets/lead_card.dart';
import '../utils/app_scroll_behavior.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({Key? key}) : super(key: key);

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  final LeadService _leadService = LeadService();

  String _query = '';
  String _statusFilter = 'All';

  // ✅ MUST MATCH AddLeadScreen
  final List<String> _statuses = [
    'All',
    'New',
    'In Progress',
    'Won',
    'Lost',
  ];

  Timer? _debounce;

 @override
void dispose() {
  _debounce?.cancel();
  _debounce = null;
  super.dispose();
}


  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _query = value.trim().toLowerCase());
      }
    });
  }

 Future<void> _editLead(Lead lead) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddLeadScreen(
        leadId: lead.id,
        initialData: {
          'name': lead.name,
          'company': lead.company,
          'email': lead.email,
          'phone': lead.phone,
          'status': lead.status,
          'source': lead.source,
          'assignedTo': lead.assignedTo,
          'notes': lead.notes,
          'tags': lead.tags,
          'score': lead.score,
        },
      ),
    ),
  );
}



  Future<void> _deleteLead(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete lead?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _leadService.deleteLead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.iconTheme.color,
      ),

      /// ➕ ADD LEAD
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-lead');
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            children: [
              // =========================
              // 🔍 SEARCH + FILTER
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black45),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search leads',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() => _query = '');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        underline: const SizedBox(),
                        items: _statuses
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _statusFilter = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =========================
              // 🏷 STATUS CHIPS
              // =========================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.where((s) => s != 'All').map((s) {
                    final selected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: selected,
                        onSelected: (sel) {
                          setState(() => _statusFilter = sel ? s : 'All');
                        },
                        selectedColor:
                            theme.primaryColor.withOpacity(0.12),
                        backgroundColor: theme.cardColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? theme.primaryColor
                              : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // 🔥 FIRESTORE STREAM
              // =========================
              Expanded(
                child: ScrollConfiguration(
                  behavior: AppScrollBehavior(),
                  child: StreamBuilder<List<Lead>>(
                    stream: _leadService.streamLeads(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final leads = snapshot.data ?? [];

                      if (leads.isEmpty) {
                        return const Center(
                          child: Text('No leads found'),
                        );
                      }

                      // =========================
                      // 🔎 FILTERING
                      // =========================
                      final filtered = leads.where((l) {
                        final matchesStatus =
                            _statusFilter == 'All' ||
                            l.status.toLowerCase() ==
                                _statusFilter.toLowerCase();

                        final matchesQuery =
                            _query.isEmpty ||
                            l.name.toLowerCase().contains(_query) ||
                            l.company.toLowerCase().contains(_query) ||
                            l.email.toLowerCase().contains(_query) ||
                            l.phone.toLowerCase().contains(_query);

                        return matchesStatus && matchesQuery;
                      }).toList();

                      // Newest first
                     filtered.sort((a, b) {
  final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return bTime.compareTo(aTime);
});


                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No leads match your filters'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final lead = filtered[i];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: LeadCard(
                                 lead: lead,
                                 onEdit: () => _editLead(lead),
                                 onDelete: () => _deleteLead(lead.id),
                             ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
