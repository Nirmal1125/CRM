import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../utils/app_scroll_behavior.dart';

enum TaskFilter { all, today, overdue, upcoming, completed }

class TasksListScreen extends StatefulWidget {
  final bool showBack;
  final TaskFilter initialFilter;

  const TasksListScreen({
    Key? key,
    this.showBack = false,
    this.initialFilter = TaskFilter.all,
  }) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  late TaskFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
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

  List<Task> _filteredTasks(TaskProvider provider) {
    List<Task> list;
    switch (_filter) {
      case TaskFilter.today:
        list = provider.todayTasks();
        break;
      case TaskFilter.overdue:
        list = provider.overdueTasks();
        break;
      case TaskFilter.upcoming:
        list = provider.upcomingTasks();
        break;
      case TaskFilter.completed:
        list = provider.completedTasks();
        break;
      default:
        list = provider.tasks;
    }

    return list.where((t) =>
        _query.isEmpty ||
        t.title.toLowerCase().contains(_query) ||
        t.description.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showBack
          ? AppBar(
              title: const Text('Tasks'),
              leading: const BackButton(),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.showBack)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tasks', style: theme.textTheme.headlineMedium),
                    ElevatedButton.icon(
                     onPressed: () async {
  await Navigator.pushNamed(context, '/add-task');

},

                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search tasks',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor:
                      isDark ? theme.colorScheme.surface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipFilter('All', TaskFilter.all),
                    _chipFilter('Today', TaskFilter.today),
                    _chipFilter('Overdue', TaskFilter.overdue),
                    _chipFilter('Upcoming', TaskFilter.upcoming),
                    _chipFilter('Completed', TaskFilter.completed),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (_, provider, __) {
                    if (provider.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final tasks = _filteredTasks(provider);

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
                          return TaskCard(
                            task: task,
                            onComplete: task.status == 'Completed'
    ? null
    : () => provider.markCompleted(task.id),

                            onDelete: () =>
                                provider.deleteTask(task.id),
                            onEdit: () {
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
                                  'reminderMinutes':
                                      task.reminderMinutes,
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

  Widget _chipFilter(String label, TaskFilter value) {
    final theme = Theme.of(context);
    final selected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
