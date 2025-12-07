import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../ui/glass_container.dart';
import 'add_customer_screen.dart';

class CustomerListScreen extends StatelessWidget {
  CustomerListScreen({super.key});

  final _service = CustomerService();

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddCustomerScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetTween = Tween(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(offsetTween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Customer c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => AddCustomerScreen(
              customerId: c.id,
              initialData: {
                'name': c.name,
                'email': c.email,
                'phone': c.phone,
                'company': c.company,
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // feels more “liquid”
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.25),
            width: 1.2,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(
            255,
            26,
            140,
            192,
          ).withOpacity(0.08),
          elevation: 0,
          heroTag: "add_customer_btn",
          onPressed: () => _openAdd(context),
          child: Icon(
            Icons.add,
            color: Colors.white.withOpacity(0.92),
            size: 30,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 159, 160, 161).withOpacity(0.9),
              const Color.fromARGB(255, 142, 193, 218),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Customer>>(
          stream: _service.streamCustomers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final customers = snapshot.data ?? [];
            if (customers.isEmpty) {
              return const Center(
                child: Text(
                  'No customers yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 16),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final c = customers[index];

                return GlassContainer(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.company,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.email,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _openEdit(context, c);
                              } else if (value == 'delete') {
                                await _service.deleteCustomer(c.id);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    )
                    // simple entrance animation (liquid feel)
                    .animate()
                    .fadeIn(delay: (index * 60).ms, duration: 250.ms)
                    .slideY(begin: 0.05, end: 0);
              },
            );
          },
        ),
      ),
    );
  }
}
