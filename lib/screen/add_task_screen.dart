import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _reminderMinutes = 30;

  String? _taskId;
  bool _isEdit = false;
  String _priority = 'medium';

  String _relatedType = 'None';
  String? _relatedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && !_isEdit) {
      _taskId = args['taskId'];
      _title.text = args['title'] ?? '';
      _desc.text = args['description'] ?? '';
      _dueDate = args['dueDate'];
      _priority = args['priority'] ?? 'medium';
      _reminderMinutes = args['reminderMinutes'] ?? 30;
      _relatedType =
          (args['relatedType'] == null || args['relatedType'] == '')
              ? 'None'
              : args['relatedType'];
      _relatedId = args['relatedId'];
      _isEdit = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? finalDueDate;
    if (_dueDate != null) {
      final time = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
      finalDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        time.hour,
        time.minute,
      );
    }

    final provider = context.read<TaskProvider>();

    if (_isEdit) {
      await provider.updateTask(
        taskId: _taskId!,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: finalDueDate,
        priority: _priority,
        relatedType: _relatedType == 'None' ? '' : _relatedType,
        relatedId: _relatedId ?? '',
        reminderMinutes: _reminderMinutes,
      );
    } else {
      await provider.addTask(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: finalDueDate,
        priority: _priority,
        relatedType: _relatedType == 'None' ? '' : _relatedType,
        relatedId: _relatedId ?? '',
        reminderMinutes: _reminderMinutes,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor:
          isDark ? theme.colorScheme.surface : const Color(0xFFF8F9FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey.withOpacity(0.4), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey.withOpacity(0.35), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'Add Task'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surface
                  : const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? 'Edit task' : 'Add new task',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _title,
                    decoration:
                        _fieldDecoration(context, 'Task title'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration:
                        _fieldDecoration(context, 'Description'),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration:
                        _fieldDecoration(context, 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(
                          value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(
                          value: 'high', child: Text('High')),
                    ],
                    onChanged: (v) =>
                        setState(() => _priority = v!),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: _reminderMinutes,
                    decoration:
                        _fieldDecoration(context, 'Reminder'),
                    items: const [
                      DropdownMenuItem(
                          value: 0, child: Text('At due time')),
                      DropdownMenuItem(
                          value: 15, child: Text('15 min before')),
                      DropdownMenuItem(
                          value: 30, child: Text('30 min before')),
                      DropdownMenuItem(
                          value: 60, child: Text('1 hour before')),
                    ],
                    onChanged: (v) =>
                        setState(() => _reminderMinutes = v!),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'No due date selected'
                              : 'Due ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                  '${_dueTime != null ? ' at ${_dueTime!.format(context)}' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                          onPressed: _pickDate,
                          child: const Text('Pick date')),
                      TextButton(
                          onPressed: _pickTime,
                          child: const Text('Pick time')),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(
                            _isEdit ? 'Save changes' : 'Add task'),
                      ),
                    ],
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
