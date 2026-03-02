import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerCard({
    Key? key,
    required this.customer,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _statusColor(BuildContext context) {
    switch (customer.status.toLowerCase()) {
      case 'customer':
        return Colors.green;
      case 'lead':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String value,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).hintColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(context);

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LEFT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  Text(
                    customer.name,
                    style: theme.textTheme.titleMedium,
                  ),

                  // COMPANY
                  if (customer.company.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.company,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // PHONE
                  _infoRow(context, Icons.phone, customer.phone),

                  // EMAIL
                  _infoRow(context, Icons.email, customer.email),

                  // CITY
                  _infoRow(context, Icons.location_on, customer.city),

                  // ORDERS + AMOUNT
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (customer.orders.isNotEmpty)
                        Text(
                          'Orders: ${customer.orders}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (customer.orders.isNotEmpty &&
                          customer.amountSpent.isNotEmpty)
                        const SizedBox(width: 16),
                      if (customer.amountSpent.isNotEmpty)
                        Text(
                          '₹${customer.amountSpent}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= RIGHT =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // STATUS
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // MENU
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
