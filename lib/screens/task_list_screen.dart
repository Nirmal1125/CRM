import 'dart:async';
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../utils/app_scroll_behavior.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({Key? key}) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TaskService _service = TaskService();
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
            ? 24
            : 32;

    final double maxContentWidth = isMobile
        ? width
        : isTablet
            ? 900
            : 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tasks',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Manage and track your tasks',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/add-task'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Task'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= SEARCH =================
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search tasks',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= TASK LIST =================
                  Expanded(
                    child: StreamBuilder<List<Task>>(
                      stream: _service.streamTasks(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final tasks = snapshot.data!;

                        // 🔍 FILTER
                        final filtered = tasks.where((t) {
                          if (_query.isEmpty) return true;
                          return t.title.toLowerCase().contains(_query) ||
                              t.description.toLowerCase().contains(_query);
                        }).toList();

                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text('No tasks found'),
                          );
                        }

                        // 📌 Open first, completed last
                        filtered.sort((a, b) {
                          if (a.status == b.status) return 0;
                          return a.status == 'Completed' ? 1 : -1;
                        });

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ScrollConfiguration(
                            behavior: AppScrollBehavior(),
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final task = filtered[i];
                                final bool completed =
                                    task.status == 'Completed';

                                return TaskCard(
                                  task: task,
                                  onComplete: completed
                                      ? () {}
                                      : () =>
                                          _service.markCompleted(task.id),
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
                                              'description':
                                                  task.description,
                                              'dueDate': task.dueDate,
                                            },
                                          );
                                        },
                                );
                              },
                            ),
                          ),
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
