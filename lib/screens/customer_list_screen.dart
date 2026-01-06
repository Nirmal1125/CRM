import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crm/screen/add_customer_screen.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../widgets/customer_card.dart'; // ✅ USE EXISTING CARD

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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.trim().toLowerCase());
    });
  }

  Future<void> _editCustomer(Customer c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(
          customerId: c.id,
          initialData: {
            'name': c.name,
            'email': c.email,
            'phone': c.phone,
            'status': c.status,
            'city': c.city,
            'orders': c.orders,
            'amountSpent': c.amountSpent,
          },
        ),
      ),
    );
  }

  Future<void> _deleteCustomer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete customer?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
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
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER (UNCHANGED) =================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Customers',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Manage and track your customers',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-customer');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= SEARCH (UNCHANGED) =================
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search customer',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

              const SizedBox(height: 20),

              // ================= CONTENT =================
              Expanded(
                child: StreamBuilder<List<Customer>>(
                  stream: _service.streamCustomers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final customers = snapshot.data!
                        .where((c) =>
                            _query.isEmpty ||
                            c.name.toLowerCase().contains(_query) ||
                            c.email.toLowerCase().contains(_query) ||
                            c.phone.toLowerCase().contains(_query))
                        .toList();

                    if (customers.isEmpty) {
                      return const Center(
                          child: Text('No customers found'));
                    }

                    // ✅ MOBILE → CARD VIEW (NO DESIGN CHANGE)
                    if (isMobile) {
                      return ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (_, i) {
                          final c = customers[i];
                          return CustomerCard(
                            customer: c,
                            onTap: () => _editCustomer(c),
                          );
                        },
                      );
                    }

                    // ✅ TABLET / DESKTOP → ORIGINAL TABLE
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildCustomerTable(customers),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TABLE (UNCHANGED) =================

  Widget _buildCustomerTable(List<Customer> customers) {
    return Column(
      children: [
        _tableHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (_, i) => _tableRow(customers[i]),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: const Color(0xFFF9FAFB),
      child: Row(
        children: const [
          Expanded(flex: 5, child: Text('Customer', style: headerStyle)),
          Expanded(flex: 2, child: Text('Status', style: headerStyle)),
          Expanded(flex: 2, child: Text('City', style: headerStyle)),
          Expanded(child: Text('Orders', style: headerStyle)),
          Expanded(child: Text('Amount', style: headerStyle)),
          SizedBox(width: 44),
        ],
      ),
    );
  }

  // ================= ROW (UNCHANGED) =================

  Widget _tableRow(Customer c) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      const Color(0xFF4F46E5),
                  child: Text(
                    c.name.isNotEmpty
                        ? c.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        c.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _statusChip(c.status)),
          Expanded(
              flex: 2,
              child: Text(c.city,
                  overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(c.orders)),
          Expanded(
              child: Text('₹${c.amountSpent}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500))),
          SizedBox(
            width: 44,
            child: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _editCustomer(c);
                if (v == 'delete') _deleteCustomer(c.id);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg, fg;
    switch (status.toLowerCase()) {
      case 'customer':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'pending':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case 'lead':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status,
          style: TextStyle(fontSize: 12, color: fg)),
    );
  }
}
