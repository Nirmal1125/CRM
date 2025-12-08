// lib/screens/leads_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../services/leads_service.dart';
import '../widgets/lead_card.dart';
// NOTE: lead_form_screen.dart intentionally NOT imported anymore

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({Key? key}) : super(key: key);

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  final LeadsService _service = LeadsService();
  List<Lead> _leads = [];
  bool _loading = true;
  String _query = '';
  String _statusFilter = 'All';
  final _statuses = ['All', 'New', 'Contacted', 'Qualified', 'Lost', 'Converted'];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final leads = await _service.getLeads(query: _query, status: _statusFilter);
    setState(() {
      _leads = leads;
      _loading = false;
    });
  }

  // Debounced search handler
  void _onSearchChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _load();
    });
  }

  // EDIT now disabled — show informational dialog
  Future<void> _onEditDisabled() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editing disabled'),
        content: const Text('Editing leads from this screen is disabled. Contact your administrator to update lead data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteLead(id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.iconTheme.color,
        // Add button removed intentionally
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Search + status dropdown row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black45),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search name, company, email or phone',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: _onSearchChanged,
                                controller: TextEditingController.fromValue(TextEditingValue(
                                  text: _query,
                                  selection: TextSelection.collapsed(offset: _query.length),
                                )),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _query = '';
                                  });
                                  _load();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status dropdown (compact)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        underline: const SizedBox(),
                        items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _statusFilter = v);
                          _load();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Status chips (horizontal scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.where((s) => s != 'All').map((s) {
                    final selected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: selected,
                        onSelected: (sel) {
                          setState(() => _statusFilter = sel ? s : 'All');
                          _load();
                        },
                        selectedColor: theme.primaryColor.withOpacity(0.12),
                        backgroundColor: theme.cardColor,
                        labelStyle: TextStyle(color: selected ? theme.primaryColor : Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Lead list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _leads.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 12),
                                const Text('No leads found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                const Text('Leads cannot be created from this screen.', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              itemCount: _leads.length,
                              itemBuilder: (ctx, i) {
                                final lead = _leads[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: LeadCard(
                                    lead: lead,
                                    // Editing is disabled now — show info dialog
                                    onEdit: _onEditDisabled,
                                    onDelete: () => _deleteLead(lead.id),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      // FloatingActionButton removed to disable adding
    );
  }
}
