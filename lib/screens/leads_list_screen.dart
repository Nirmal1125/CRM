import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crm/screen/add_lead_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _query = '';
  String _statusFilter = 'All';

  final List<String> _statuses = [
    'All',
    'New',
    'In Progress',
    'Won',
    'Lost',
    'Converted',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _leadService.deleteLead(id);
    }
  }

  Future<void> _convertLead(Lead lead) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Convert Lead'),
        content: const Text(
          'This will convert the lead into a customer. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Convert'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _leadService.convertLeadToCustomer(lead);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lead converted to customer')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
            ? 24
            : 32;

    final double maxContentWidth = isMobile
        ? width
        : isTablet
            ? 900
            : 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Leads',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Manage and track your leads',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/add-lead'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Lead'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= SEARCH =================
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search leads',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= STATUS FILTER =================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statuses.map((s) {
                        final selected = _statusFilter == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _statusFilter = s);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= LEADS LIST =================
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ScrollConfiguration(
                        behavior: AppScrollBehavior(),
                        child: StreamBuilder<List<Lead>>(
                          stream: _leadService.streamLeads(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final filtered = snapshot.data!.where((l) {
                              final matchesStatus =
                                  _statusFilter == 'All' ||
                                  l.status.toLowerCase() ==
                                      _statusFilter.toLowerCase();

                              final matchesQuery =
                                  _query.isEmpty ||
                                  l.name.toLowerCase().contains(_query) ||
                                  l.email.toLowerCase().contains(_query) ||
                                  l.phone.toLowerCase().contains(_query);

                              return matchesStatus && matchesQuery;
                            }).toList();

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text('No leads found'),
                              );
                            }

                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final lead = filtered[i];
                                return LeadCard(
                                  lead: lead,
                                 onEdit: lead.status.toLowerCase() == 'converted'
                                             ? null
                                                : () => _editLead(lead),

                                  onDelete: () => _deleteLead(lead.id),
                                  onConvert: lead.status == 'Converted'
                                      ? null
                                      : () => _convertLead(lead),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
