// lib/screens/customer_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';

class CustomerListScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDark;
  const CustomerListScreen({Key? key, this.onToggleTheme, required this.isDark}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late List<Customer> _customers;
  List<Customer> _filtered = [];
  final Set<String> _selectedIds = {};
  bool _selectAll = false;
  bool _sortAsc = true;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _customers = _buildDummyData();
    _filtered = List.from(_customers);
    _searchController.addListener(_onSearchChangedDebounced);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChangedDebounced);
    _searchController.dispose();
    super.dispose();
  }

  // Debounced search (200ms)
  void _onSearchChangedDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _customers.where((c) {
        final matchesQuery = q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            (c.city ?? '').toLowerCase().contains(q);
        final matchesStatus = _statusFilter == 'All' || c.status.toLowerCase() == _statusFilter.toLowerCase();
        return matchesQuery && matchesStatus;
      }).toList();
      _sortList();
      _selectAll = _filtered.isNotEmpty && _selectedIds.length == _filtered.length;
    });
  }

  void _sortList() {
    _filtered.sort((a, b) => _sortAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }

  // Selection
  void _toggleSelectAll(bool? v) {
    setState(() {
      _selectAll = v ?? false;
      _selectedIds.clear();
      if (_selectAll) for (var c in _filtered) _selectedIds.add(c.id);
    });
  }

  void _toggleSelectOne(String id, bool? value) {
    setState(() {
      if (value == true)
        _selectedIds.add(id);
      else
        _selectedIds.remove(id);
      _selectAll = _filtered.isNotEmpty && _selectedIds.length == _filtered.length;
    });
  }

  // Bulk delete
  void _deleteSelected() {
    final count = _selectedIds.length;
    if (count == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count selected'),
        content: Text('Are you sure you want to delete $count selected customer(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customers.removeWhere((c) => _selectedIds.contains(c.id));
                _selectedIds.clear();
                _selectAll = false;
              });
              _applyFilters();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted $count customer(s)')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelected() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No customers selected')));
      return;
    }
    final rows = _customers.where((c) => _selectedIds.contains(c.id)).map((c) {
      final r = [
        c.name.replaceAll(',', ' '),
        c.email,
        c.phone,
        c.status,
        c.city ?? '',
        c.orders ?? '',
        c.amountSpent ?? '',
      ];
      return r.join(',');
    }).join('\n');
    final csv = 'name,email,phone,status,city,orders,amountSpent\n$rows';
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected CSV copied to clipboard')));
  }

  // Import (paste CSV)
  void _onImport() async {
    final textController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import customers (paste CSV)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Paste CSV data with columns: name,email,phone,status,city'),
            const SizedBox(height: 8),
            TextField(controller: textController, maxLines: 8, decoration: const InputDecoration(hintText: 'name,email,phone,status,city\n...')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final csv = textController.text.trim();
              if (csv.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data pasted')));
                return;
              }
              _parseAndAddCsv(csv);
              Navigator.pop(ctx);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _parseAndAddCsv(String csv) {
    final lines = csv.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    int added = 0;
    for (var i = 0; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 2) continue;
      final name = parts[0].trim();
      final email = parts[1].trim();
      final phone = parts.length > 2 ? parts[2].trim() : '';
      final status = parts.length > 3 ? parts[3].trim() : 'Lead';
      final city = parts.length > 4 ? parts[4].trim() : '';
      final newC = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        name: name,
        phone: phone,
        email: email,
        status: status,
        city: city,
        orders: '0 Orders',
        amountSpent: '\$0.00',
      );
      _customers.insert(0, newC);
      added++;
    }
    _applyFilters();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $added customers')));
  }

  // Export all filtered
  void _onExport() {
    final header = 'name,email,phone,status,city,orders,amountSpent';
    final rows = _filtered.map((c) {
      final row = [
        c.name.replaceAll(',', ' '),
        c.email,
        c.phone,
        c.status,
        c.city ?? '',
        c.orders ?? '',
        c.amountSpent ?? '',
      ];
      return row.join(',');
    }).join('\n');
    final csv = '$header\n$rows';
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
  }

  // -----------------------
  // Add/Edit handling:
  // Try to navigate to '/add-customer' route; if push fails (no route), show external dialog.
  // -----------------------

  Future<void> _showExternalAddDialog({String mode = 'Add', Customer? customer}) async {
    const csvTemplate = 'name,email,phone,status,city\nJohn Doe,john@example.com,9876543210,Lead,City';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$mode customer (handled externally)'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Adding or editing customers is handled outside this screen.'),
          const SizedBox(height: 8),
          const Text('You can copy a CSV template to share with the person who will add customers:'),
          const SizedBox(height: 8),
          SelectableText(csvTemplate, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: csvTemplate));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV template copied')));
            },
            child: const Text('Copy CSV template'),
          ),
        ],
      ),
    );
  }

  // Attempt to open add-customer route; fallback to dialog if route missing
  Future<void> _openAddCustomer({Customer? prefill, bool isEdit = false}) async {
    try {
      final result = await Navigator.pushNamed(context, '/add-customer', arguments: prefill);
      if (result != null && result is Map) {
        final data = result;
        if (isEdit && prefill != null) {
          setState(() {
            final idx = _customers.indexWhere((c) => c.id == prefill.id);
            if (idx != -1) {
              _customers[idx] = Customer(
                id: prefill.id,
                name: data['name'] ?? prefill.name,
                phone: data['phone'] ?? prefill.phone,
                email: data['email'] ?? prefill.email,
                status: data['status'] ?? prefill.status,
                city: data['city'] ?? prefill.city,
                orders: prefill.orders,
                amountSpent: prefill.amountSpent,
              );
            }
          });
        } else {
          final newCust = Customer(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: data['name'] ?? '',
            phone: data['phone'] ?? '',
            email: data['email'] ?? '',
            status: data['status'] ?? 'Lead',
            city: data['city'] ?? '',
            orders: '0 Orders',
            amountSpent: '\$0.00',
          );
          setState(() {
            _customers.insert(0, newCust);
          });
        }
        _applyFilters();
      }
    } catch (e) {
      await _showExternalAddDialog(mode: isEdit ? 'Edit' : 'Add', customer: prefill);
    }
  }

  // Edit: attempt route, otherwise fallback to dialog
  Future<void> _onEdit(Customer c) async {
    try {
      final result = await Navigator.pushNamed(context, '/add-customer', arguments: c);
      if (result != null && result is Map) {
        final data = result;
        setState(() {
          final idx = _customers.indexWhere((x) => x.id == c.id);
          if (idx != -1) {
            _customers[idx] = Customer(
              id: c.id,
              name: data['name'] ?? c.name,
              phone: data['phone'] ?? c.phone,
              email: data['email'] ?? c.email,
              status: data['status'] ?? c.status,
              city: data['city'] ?? c.city,
              orders: c.orders,
              amountSpent: c.amountSpent,
            );
          }
        });
        _applyFilters();
      }
    } catch (e) {
      await _showExternalAddDialog(mode: 'Edit', customer: c);
    }
  }

  void _onView(Customer c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c.name),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Email: ${c.email}'),
          Text('Phone: ${c.phone}'),
          Text('Status: ${c.status}'),
          Text('Location: ${c.city ?? '-'}'),
          Text('Orders: ${c.orders ?? '-'}'),
          Text('Amount: ${c.amountSpent ?? '-'}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _onDelete(Customer c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer'),
        content: Text('Are you sure you want to delete ${c.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customers.removeWhere((x) => x.id == c.id);
                _selectedIds.remove(c.id);
              });
              _applyFilters();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${c.name} deleted')));
            },
            child: const Text('Delete'),
          )
        ],
      ),
    );
  }

  void _toggleSort() {
    setState(() {
      _sortAsc = !_sortAsc;
      _sortList();
    });
  }

  // filter sheet method
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        String localFilter = _statusFilter;
        return StatefulBuilder(builder: (context, setLocalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Filter by subscription status', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', 'Subscribed', 'Not subscribed', 'Pending'].map((s) {
                  final sel = localFilter == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: sel,
                    onSelected: (_) => setLocalState(() => localFilter = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _statusFilter = localFilter);
                    _applyFilters();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ])
            ]),
          );
        });
      },
    );
  }

  // Build UI (responsive)
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW >= 1100;
    final isMedium = screenW >= 700 && screenW < 1100;
    final isSmall = screenW < 700;
    final theme = Theme.of(context);
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // HEADER: title + constrained actions (prevents overflow)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title area - allows shrinking
                Expanded(
                  child: Text('Customers', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),

                const SizedBox(width: 12),

                // Actions: constrained to half of available width and horizontally scrollable
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenW * 0.5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Tooltip(message: 'Import customers', child: TextButton.icon(onPressed: _onImport, icon: const Icon(Icons.upload_file), label: const Text('Import'))),
                        const SizedBox(width: 8),
                        Tooltip(message: 'Export customers', child: TextButton.icon(onPressed: _onExport, icon: const Icon(Icons.download), label: const Text('Export'))),
                        const SizedBox(width: 12),
                        Tooltip(message: 'Add new customer', child: ElevatedButton(onPressed: () => _openAddCustomer(), child: const Text('Add Customers'))),
                        const SizedBox(width: 12),
                        IconButton(tooltip: widget.isDark ? 'Switch to Light' : 'Switch to Dark', onPressed: widget.onToggleTheme, icon: Icon(widget.isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('As a new CRM member, get ready for an exciting shopping journey with perks.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 18),

            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Text('${_customers.length} customers', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  const Text('100% of your customer base', style: TextStyle(color: Colors.grey)),
                ]),
              ),
              const Spacer(),
              TextButton(onPressed: _openFilterSheet, child: const Text('Add filter')),
            ]),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search customer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _applyFilters(); }) : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(message: _sortAsc ? 'Sort A→Z' : 'Sort Z→A', child: IconButton(onPressed: _toggleSort, icon: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.sort_by_alpha), const SizedBox(width: 4), Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 18),]))),
            ]),

            const SizedBox(height: 16),

            if (hasSelection)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(children: [
                  Text('${_selectedIds.length} selected', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _deleteSelected, icon: const Icon(Icons.delete), label: const Text('Delete selected')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(onPressed: _exportSelected, icon: const Icon(Icons.download), label: const Text('Export selected')),
                  const Spacer(),
                  TextButton(onPressed: () => setState(() { _selectedIds.clear(); _selectAll = false; }), child: const Text('Clear selection')),
                ]),
              ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [if (theme.brightness == Brightness.light) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: _filtered.isEmpty ? _buildEmptyState() : (isSmall ? _buildListView() : _buildResponsiveTable(isMedium: isMedium, isWide: isWide)),
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openAddCustomer(), tooltip: 'Add customer', child: const Icon(Icons.add)),
    );
  }

  Widget _buildResponsiveTable({required bool isMedium, required bool isWide}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          headingRowHeight: 48,
          dataRowHeight: 72,
          columnSpacing: 20,
          dividerThickness: 0,
          headingRowColor: MaterialStateProperty.resolveWith((_) => Colors.transparent),
          columns: [
            DataColumn(label: Checkbox(value: _selectAll, onChanged: _toggleSelectAll)),
            const DataColumn(label: Text('Customer')),
            const DataColumn(label: Text('Email Subscription')),
            const DataColumn(label: Text('Location')),
            if (isWide) const DataColumn(label: Text('Orders')),
            if (isWide) const DataColumn(label: Text('Amount Spent')),
            const DataColumn(label: Text('Action')),
          ],
          rows: _filtered.map((c) {
            final selected = _selectedIds.contains(c.id);
            return DataRow(cells: [
              DataCell(Checkbox(value: selected, onChanged: (v) => _toggleSelectOne(c.id, v))),
              DataCell(_buildCustomerCellConstrained(c)),
              DataCell(_buildStatusBadge(c.status)),
              DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: 220), child: Text(c.city ?? '—', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)))),
              if (isWide) DataCell(Text(c.orders ?? '—', style: const TextStyle(color: Colors.black87))),
              if (isWide) DataCell(Text(c.amountSpent ?? '—', style: const TextStyle(color: Colors.black87))),
              DataCell(_buildActionMenu(c)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomerCellConstrained(Customer c) {
    return Row(children: [
      CircleAvatar(radius: 18, child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
      const SizedBox(width: 10),
      ConstrainedBox(constraints: const BoxConstraints(maxWidth: 260), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(c.email, style: const TextStyle(color: Colors.black54, fontSize: 12), overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = _filtered[index];
        final selected = _selectedIds.contains(c.id);
        return ListTile(
          leading: Checkbox(value: selected, onChanged: (v) => _toggleSelectOne(c.id, v)),
          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${c.city ?? ''} • ${c.email}', style: const TextStyle(color: Colors.black54)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            _buildStatusBadge(c.status),
            const SizedBox(width: 8),
            PopupMenuButton<String>(tooltip: 'Row actions', onSelected: (value) { if (value == 'view') _onView(c); if (value == 'edit') _onEdit(c); }, itemBuilder: (_) => const [
              PopupMenuItem(value: 'view', child: Text('View')),
              PopupMenuItem(value: 'edit', child: Text('Edit')),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.person_off, size: 64, color: Colors.grey),
      const SizedBox(height: 12),
      const Text('No customers found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Add your first customer to get started.', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: () => _openAddCustomer(), child: const Text('Add Customer')),
    ]));
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color color;
    if (s.contains('subscribed')) color = Colors.green;
    else if (s.contains('not')) color = Colors.red;
    else color = Colors.orange;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)));
  }

  Widget _buildActionMenu(Customer c) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (value) { if (value == 'view') _onView(c); if (value == 'edit') _onEdit(c); if (value == 'delete') _onDelete(c); },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'view', child: Text('View')),
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  // Dummy data
  List<Customer> _buildDummyData() {
    return [
      Customer(id: '1', name: 'Esther Howard', phone: '+91 98765 43210', email: 'esther@example.com', status: 'Subscribed', city: 'Great Falls, Maryland', orders: '2 Orders', amountSpent: '\$250.00'),
      Customer(id: '2', name: 'Leslie Alexander', phone: '+91 91234 56789', email: 'leslie@example.com', status: 'Not subscribed', city: 'Pasadena, Oklahoma', orders: '3 Orders', amountSpent: '\$350.00'),
      Customer(id: '3', name: 'Guy Hawkins', phone: '+91 99887 66554', email: 'guy@example.com', status: 'Pending', city: 'Corona, Michigan', orders: 'N/A', amountSpent: '\$0.00'),
      Customer(id: '4', name: 'Savannah Nguyen', phone: '+91 90000 11111', email: 'savannah@example.com', status: 'Subscribed', city: 'Syracuse, Connecticut', orders: 'N/A', amountSpent: '\$0.00'),
      Customer(id: '5', name: 'Bessie Cooper', phone: '+91 91111 22222', email: 'bessie@example.com', status: 'Not subscribed', city: 'Lansing, Illinois', orders: '1 Orders', amountSpent: '\$470.00'),
      Customer(id: '6', name: 'Ronald Richards', phone: '+91 92222 33333', email: 'ronald@example.com', status: 'Pending', city: 'Great Falls, Maryland', orders: '2 Orders', amountSpent: '\$250.00'),
      Customer(id: '7', name: 'Marvin McKinney', phone: '+91 93333 44444', email: 'marvin@example.com', status: 'Subscribed', city: 'Coppell, Virginia', orders: '2 Orders', amountSpent: '\$150.00'),
      Customer(id: '8', name: 'Kathryn Murphy', phone: '+91 94444 55555', email: 'kathryn@example.com', status: 'Not subscribed', city: 'Lafayette, California', orders: '3 Orders', amountSpent: '\$250.00'),
      Customer(id: '9', name: 'Eleanor Pena', phone: '+91 95555 66666', email: 'eleanor@example.com', status: 'Pending', city: 'Corona, Michigan', orders: '1 Orders', amountSpent: '\$250.00'),
    ];
  }
}
