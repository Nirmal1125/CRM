import 'package:flutter/material.dart';
import '../models/lead.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onConvert;

  const LeadCard({
    Key? key,
    required this.lead,
    this.onEdit,
    this.onDelete,
    this.onConvert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final created = lead.createdAt;

    final String createdStr = created == null
        ? '—'
        : '${created.day.toString().padLeft(2, '0')}/'
          '${created.month.toString().padLeft(2, '0')}/'
          '${created.year}';

    final bool isConverted =
        lead.status.toLowerCase() == 'converted';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LEFT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lead.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (lead.status.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lead.status,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (lead.company.isNotEmpty)
                    Text(
                      lead.company,
                      style: const TextStyle(color: Colors.black54),
                    ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      if (lead.email.isNotEmpty) ...[
                        const Icon(Icons.email,
                            size: 14, color: Colors.black38),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            lead.email,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (lead.phone.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.phone,
                            size: 14, color: Colors.black38),
                        const SizedBox(width: 6),
                        Text(
                          lead.phone,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ================= RIGHT =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score: ${lead.score ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  createdStr,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔁 Convert button (ONLY if not converted)
                    if (!isConverted && onConvert != null)
                      TextButton(
                        onPressed: onConvert,
                        child: const Text('Convert'),
                      ),

                    // ✏️ Edit (DISABLED if converted)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: isConverted ? null : onEdit,
                      tooltip: isConverted
                          ? 'Converted leads cannot be edited'
                          : 'Edit',
                    ),

                    // 🗑 Delete (always allowed)
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
