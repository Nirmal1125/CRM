import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TaskService();

  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime? _dueDate;
  String? _taskId;
  bool _isEdit = false;

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

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit && _taskId != null) {
      // ✏️ UPDATE TASK
      await _service.updateTask(
        taskId: _taskId!,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: _dueDate,
      );
    } else {
      // ➕ ADD TASK
      await _service.addTask(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: _dueDate,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Task' : 'Add Task',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // TITLE
                    // =========================
                    const Text(
                      'Task Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =========================
                    // TASK TITLE
                    // =========================
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: 'Task title',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // DESCRIPTION
                    // =========================
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // DUE DATE
                    // =========================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'No due date selected'
                                  : 'Due: ${_dueDate!.day.toString().padLeft(2, '0')}/'
                                      '${_dueDate!.month.toString().padLeft(2, '0')}/'
                                      '${_dueDate!.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text('Pick date'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // SAVE BUTTON
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isEdit ? 'Update Task' : 'Add Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
