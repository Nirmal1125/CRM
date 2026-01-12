import 'package:flutter/material.dart';
import '../models/lead.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onConvert;

  const LeadCard({
    super.key,
    required this.lead,
    this.onEdit,
    this.onDelete,
    this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConverted = lead.status == 'Converted';

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LEFT CONTENT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- TITLE + STATUS ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          lead.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lead.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (lead.company.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      lead.company,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  // ---------- EMAIL ----------
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lead.email,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ================= RIGHT ACTIONS =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score: ${lead.score ?? 0}',
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 6),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'convert') onConvert?.call();
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (!isConverted && onConvert != null)
                      const PopupMenuItem(
                        value: 'convert',
                        child: Text('Convert'),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
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
