import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../provider/customer_provider.dart';
import '../widgets/customer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
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
      if (mounted) {
        setState(() => _query = value.trim().toLowerCase());
      }
    });
  }

  Future<void> _editCustomer(Customer c) async {
    await Navigator.pushNamed(
      context,
      '/add-customer',
      arguments: {
        'customerId': c.id,
        'name': c.name,
        'email': c.email,
        'phone': c.phone,
        'company': c.company,
        'status': c.status,
        'city': c.city,
        'orders': c.orders,
        'amountSpent': c.amountSpent,
      },
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
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<CustomerProvider>().deleteCustomer(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final double horizontalPadding =
        width < 700 ? 16 : width < 1100 ? 24 : 32;
    final double maxWidth =
        width < 700 ? width : width < 1100 ? 900 : 1200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customers',
                              style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Manage and track your customers',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/add-customer'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SEARCH
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: theme.colorScheme.onSurfaceVariant),
                      hintText: 'Search customer',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LIST
                  Expanded(
                    child: Consumer<CustomerProvider>(
                      builder: (_, provider, __) {
                        if (provider.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final customers = provider.customers.where((c) {
                          return _query.isEmpty ||
                              c.name.toLowerCase().contains(_query) ||
                              c.email.toLowerCase().contains(_query) ||
                              c.phone.toLowerCase().contains(_query) ||
                              c.company.toLowerCase().contains(_query);
                        }).toList();

                        if (customers.isEmpty) {
                          return const Center(
                              child: Text('No customers found'));
                        }

                        return ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (_, i) {
                            final c = customers[i];
                            return CustomerCard(
                              customer: c,
                              onEdit: () => _editCustomer(c),
                              onDelete: () => _deleteCustomer(c.id),
                            );
                          },
                        );
                      },
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
