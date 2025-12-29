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
    final dueText = due == null
        ? 'No due date'
        : 'Due ${due.day}/${due.month}/${due.year}';

    final bool completed = task.status == 'Completed';

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
          // ✔ STATUS ICON
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

          // 📝 CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],

                const SizedBox(height: 8),

                Row(
                  children: [
                    // STATUS CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: completed
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: completed
                              ? const Color(0xFF065F46)
                              : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // DUE DATE
                    Text(
                      dueText,
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

          // ✏️ EDIT (DISABLED IF COMPLETED)
          IconButton(
            icon: const Icon(Icons.edit),
            color: completed ? Colors.grey : Colors.blue,
            onPressed: completed ? null : onEdit,
            tooltip:
                completed ? 'Completed tasks cannot be edited' : 'Edit task',
          ),

          // 🗑 DELETE
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
