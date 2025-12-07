// lib/widgets/lead_card.dart
import 'package:flutter/material.dart';
import '../models/lead.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LeadCard({
    Key? key,
    required this.lead,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final created = lead.createdAt;
    final createdStr = '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Left: main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(lead.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 8),
                      if (lead.status.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(lead.status, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (lead.company.isNotEmpty) Text(lead.company, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (lead.email.isNotEmpty) ...[
                        Icon(Icons.email, size: 14, color: Colors.black38),
                        const SizedBox(width: 6),
                        Flexible(child: Text(lead.email, style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 12),
                      ],
                      if (lead.phone.isNotEmpty) ...[
                        Icon(Icons.phone, size: 14, color: Colors.black38),
                        const SizedBox(width: 6),
                        Text(lead.phone, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Right: score / date / actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Score: ${lead.score ?? 0}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(createdStr, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
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
