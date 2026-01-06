import 'dart:async';
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../utils/app_scroll_behavior.dart';

enum TaskFilter { all, today, overdue, upcoming, completed }

class TasksListScreen extends StatefulWidget {
  final bool showBack;          // ✅ NEW
  final TaskFilter initialFilter; // ✅ NEW

  const TasksListScreen({
    Key? key,
    this.showBack = false,
    this.initialFilter = TaskFilter.all,
  }) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TaskService _service = TaskService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _query = '';
  late TaskFilter _filter; // ✅ late init

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter; // ✅ set from dashboard
  }

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

  Stream<List<Task>> _getStream() {
    switch (_filter) {
      case TaskFilter.today:
        return _service.streamTodayTasks();
      case TaskFilter.overdue:
        return _service.streamOverdueTasks();
      case TaskFilter.upcoming:
        return _service.streamUpcomingTasks();
      case TaskFilter.completed:
        return _service.streamCompletedTasks();
      case TaskFilter.all:
      default:
        return _service.streamTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),

      // ✅ BACK ARROW ONLY WHEN OPENED FROM DASHBOARD
      appBar: widget.showBack
          ? AppBar(
              title: const Text('Tasks'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (unchanged)
              if (!widget.showBack)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tasks',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-task'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // SEARCH
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search tasks',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // FILTERS
              Wrap(
                spacing: 8,
                children: [
                  _chip('All', TaskFilter.all),
                  _chip('Today', TaskFilter.today),
                  _chip('Overdue', TaskFilter.overdue),
                  _chip('Upcoming', TaskFilter.upcoming),
                  _chip('Completed', TaskFilter.completed),
                ],
              ),

              const SizedBox(height: 16),

              // LIST
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: _getStream(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    final tasks = snapshot.data!
                        .where((t) =>
                            _query.isEmpty ||
                            t.title.toLowerCase().contains(_query) ||
                            t.description
                                .toLowerCase()
                                .contains(_query))
                        .toList();

                    if (tasks.isEmpty) {
                      return const Center(child: Text('No tasks found'));
                    }

                    return ScrollConfiguration(
                      behavior: AppScrollBehavior(),
                      child: ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final task = tasks[i];
                          final completed = task.status == 'Completed';

                          return TaskCard(
                            task: task,
                            onComplete: completed
                                ? () {}
                                : () => _service.markCompleted(task.id),
                            onDelete: () =>
                                _service.deleteTask(task.id),
                            onEdit: completed
                                ? () {}
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/add-task',
                                      arguments: {
                                        'taskId': task.id,
                                        'title': task.title,
                                        'description': task.description,
                                        'dueDate': task.dueDate,
                                        'priority': task.priority,
                                        'relatedType': task.relatedType,
                                        'relatedId': task.relatedId,
                                      },
                                    );
                                  },
                          );
                        },
                      ),
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

  Widget _chip(String label, TaskFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
