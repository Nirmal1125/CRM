import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/lead_provider.dart';
import '../widgets/lead_card.dart';
import '../utils/app_scroll_behavior.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({Key? key}) : super(key: key);

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
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
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<LeadProvider>();

    final leads = provider.filtered(
      query: _query,
      status: _statusFilter,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Leads', style: theme.textTheme.headlineMedium),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/add-lead'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Lead'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SEARCH
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search leads',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // STATUS FILTER
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.map((s) {
                    final selected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _statusFilter = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: selected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // LIST
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : leads.isEmpty
                        ? const Center(child: Text('No leads found'))
                        : ScrollConfiguration(
                            behavior: AppScrollBehavior(),
                            child: ListView.separated(
                              itemCount: leads.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final lead = leads[i];
                                return LeadCard(
                                  lead: lead,
                                  onEdit: lead.status == 'Converted'
    ? null
    : () async {
        final result = await Navigator.pushNamed(
          context,
          '/add-lead',
          arguments: {
            'leadId': lead.id, // ✅ CRITICAL FIX
            ...lead.toMap(),
          },
        );

        if (result == true && mounted) {
          setState(() {}); // optional, Provider already updates
        }
      },

                                  onDelete: () =>
                                      provider.deleteLead(lead.id),
                                  onConvert: lead.status == 'Converted'
                                      ? null
                                      : () => provider.convertLead(lead),
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
