import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate;
    final completed = task.status == 'Completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: completed ? Colors.green : Colors.grey,
            ),
            onPressed: completed ? null : onComplete,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],

                const SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _statusChip(task.status),

                    // 📅 DUE DATE + TIME
                    if (due != null)
                      Text(
                        'Due ${_formatDateTime(context, due)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),

                    // 🔔 REMINDER INFO (ONLY ADDITION)
                    if (due != null)
                      Text(
                        _reminderText(task.reminderMinutes),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),

                    if (task.relatedType.isNotEmpty)
                      Text(
                        '${task.relatedType} linked',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: completed ? null : onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  String _formatDateTime(BuildContext context, DateTime date) {
    final time = TimeOfDay.fromDateTime(date).format(context);
    return '${date.day}/${date.month}/${date.year} at $time';
  }

  String _reminderText(int minutes) {
    if (minutes == 0) {
      return '⏰ Reminder: At due time';
    }
    return '⏰ Reminder: $minutes min before';
  }

  Widget _statusChip(String status) {
    final completed = status == 'Completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: completed
              ? const Color(0xFF065F46)
              : const Color(0xFF1E40AF),
        ),
      ),
    );
  }
}
