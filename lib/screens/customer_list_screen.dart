import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crm/screen/add_customer_screen.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _service = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _query = '';
  bool _sortAsc = true;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => _query = value.trim().toLowerCase());
    });
  }

  // =========================
  // ✏️ EDIT CUSTOMER
  // =========================
  Future<void> _editCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(
          customerId: customer.id,
          initialData: {
            'name': customer.name,
            'email': customer.email,
            'phone': customer.phone,
            'status': customer.status,
            'city': customer.city,
            'orders': customer.orders,
            'amountSpent': customer.amountSpent,
          },
        ),
      ),
    );
  }

  // =========================
  // 🗑 DELETE CUSTOMER
  // =========================
  Future<void> _deleteCustomer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer?'),
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
      await _service.deleteCustomer(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customers',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// SEARCH + SORT
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search customer',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Sort by name',
                    icon: const Icon(Icons.sort_by_alpha),
                    onPressed: () =>
                        setState(() => _sortAsc = !_sortAsc),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔥 STREAM
              Expanded(
                child: StreamBuilder<List<Customer>>(
                  stream: _service.streamCustomers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final customers = snapshot.data ?? [];

                    if (customers.isEmpty) {
                      return const Center(
                        child: Text('No customers found'),
                      );
                    }

                    /// FILTER
                    final filtered = customers.where((c) {
                      if (_query.isEmpty) return true;

                      return c.name.toLowerCase().contains(_query) ||
                          c.email.toLowerCase().contains(_query) ||
                          c.city.toLowerCase().contains(_query) ||
                          c.status.toLowerCase().contains(_query);
                    }).toList();

                    /// SORT
                    filtered.sort((a, b) => _sortAsc
                        ? a.name.compareTo(b.name)
                        : b.name.compareTo(a.name));

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('No matching customers'),
                      );
                    }

                    return isMobile
                        ? _buildMobileList(filtered)
                        : _buildDesktopTable(filtered);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      /// ADD CUSTOMER
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-customer');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================
  // 📱 MOBILE LIST
  // =========================
  Widget _buildMobileList(List<Customer> customers) {
    return ListView.separated(
      itemCount: customers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final c = customers[index];
        return ListTile(
          title: Text(
            c.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.email.isNotEmpty) Text(c.email),
              if (c.phone.isNotEmpty) Text(c.phone),
              if (c.city.isNotEmpty) Text(c.city),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editCustomer(c),
              ),
              IconButton(
                icon: const Icon(Icons.delete,
                    size: 20, color: Colors.red),
                onPressed: () => _deleteCustomer(c.id),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // 💻 DESKTOP TABLE
  // =========================
  Widget _buildDesktopTable(List<Customer> customers) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Amount Spent')),
          DataColumn(label: Text('Actions')),
        ],
        rows: customers.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c.name)),
              DataCell(Text(c.email)),
              DataCell(Text(c.phone)),
              DataCell(Text(c.status)),
              DataCell(Text(c.city)),
              DataCell(Text(c.orders)),
              DataCell(Text(c.amountSpent)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editCustomer(c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          size: 18, color: Colors.red),
                      onPressed: () => _deleteCustomer(c.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
