import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  // ================= DATE FORMATTER =================
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();

    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final isTomorrow =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    String day;
    if (isToday) {
      day = 'Today';
    } else if (isTomorrow) {
      day = 'Tomorrow';
    } else {
      day = '${_month(date.month)} ${date.day}, ${date.year}';
    }

    final hour =
        date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';

    return '$day · $hour:$minute $ampm';
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  Color _priorityColor(BuildContext context) {
    switch (task.priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _statusColor(BuildContext context) {
    return task.status == 'Completed'
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = task.status == 'Completed';
    final priorityColor = _priorityColor(context);
    final statusColor = _statusColor(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COMPLETE ICON
            IconButton(
              icon: Icon(
                completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: completed ? Colors.green : theme.iconTheme.color,
              ),
              onPressed: completed ? null : onComplete,
            ),

            const SizedBox(width: 8),

            // MAIN CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // META INFO
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _meta(
                        context,
                        Icons.flag,
                        'Priority: ${task.priority}',
                        priorityColor,
                      ),

                      if (task.dueDate != null)
                        _meta(
                          context,
                          Icons.calendar_today,
                          'Due: ${_formatDateTime(task.dueDate!)}',
                          theme.hintColor,
                        ),

                      _meta(
                        context,
                        Icons.alarm,
                        'Reminder: ${task.reminderMinutes} min',
                        theme.hintColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // RIGHT ACTIONS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

               PopupMenuButton<String>(
  onSelected: (v) {
    if (v == 'edit' && task.status != 'Completed') {
      onEdit();
    }
    if (v == 'delete') {
      onDelete();
    }
  },
  itemBuilder: (_) => [
    PopupMenuItem(
      value: 'edit',
      enabled: task.status != 'Completed', // ✅ disable edit
      child: Text(
        'Edit',
        style: TextStyle(
          color: task.status == 'Completed'
              ? Colors.grey
              : Colors.black,
        ),
      ),
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

  // ================= META ROW (FIXED) =================
  Widget _meta(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),

        // ✅ THIS IS THE FIX
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
