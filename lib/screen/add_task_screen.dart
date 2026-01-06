import 'package:cloud_firestore/cloud_firestore.dart';
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
  TimeOfDay? _dueTime; // ✅ NEW (ONLY ADDITION)
  int _reminderMinutes = 30; // ✅ NEW
  String? _taskId;
  bool _isEdit = false;

  String _priority = 'medium';

  // ================= RELATION =================
  String _relatedType = 'None';
  String? _relatedId;

  String _originalRelatedType = '';
  String _originalRelatedId = '';
  

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

      _originalRelatedType = args['relatedType'] ?? '';
      _originalRelatedId = args['relatedId'] ?? '';

      _isEdit = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  // ================= TIME PICKER (NEW) =================
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  // ================= SAVE =================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ COMBINE DATE + TIME (IMPORTANT)
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

    final finalRelatedType =
        _relatedType == 'None' ? _originalRelatedType : _relatedType;
    final finalRelatedId =
        _relatedType == 'None' ? _originalRelatedId : _relatedId ?? '';

    if (_isEdit) {
  await _service.updateTask(
    taskId: _taskId!,
    title: _title.text.trim(),
    description: _desc.text.trim(),
    dueDate: finalDueDate,
    priority: _priority,
    relatedType: finalRelatedType,
    relatedId: finalRelatedId,
    reminderMinutes: _reminderMinutes, // ✅
  );
} else {
  await _service.addTask(
    title: _title.text.trim(),
    description: _desc.text.trim(),
    dueDate: finalDueDate,
    priority: _priority,
    relatedType: _relatedType == 'None' ? '' : _relatedType,
    relatedId: _relatedId ?? '',
    reminderMinutes: _reminderMinutes, // ✅
  );
}


    if (mounted) Navigator.pop(context);
  }

  // ================= FETCH RELATED =================
  Stream<QuerySnapshot<Map<String, dynamic>>> _relatedStream() {
    if (_relatedType == 'lead') {
      return FirebaseFirestore.instance
          .collection('leads')
          .where('status', isNotEqualTo: 'Converted')
          .snapshots();
    }
    if (_relatedType == 'customer') {
      return FirebaseFirestore.instance.collection('customers').snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(title: Text(_isEdit ? 'Edit Task' : 'Add Task')),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _title,
                      decoration: _inputDecoration('Task title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Title is required'
                              : null,
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: _inputDecoration('Description'),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: _inputDecoration('Priority'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
const SizedBox(height: 20),

DropdownButtonFormField<int>(
  value: _reminderMinutes,
  decoration: _inputDecoration('Reminder'),
  items: const [
    DropdownMenuItem(value: 0, child: Text('At due time')),
    DropdownMenuItem(value: 5, child: Text('5 minutes before')),
    DropdownMenuItem(value: 15, child: Text('15 minutes before')),
    DropdownMenuItem(value: 30, child: Text('30 minutes before')),
    DropdownMenuItem(value: 60, child: Text('1 hour before')),
  ],
  onChanged: (v) => setState(() => _reminderMinutes = v!),
),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _relatedType,
                      decoration: _inputDecoration('Related to'),
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('None')),
                        DropdownMenuItem(value: 'lead', child: Text('Lead')),
                        DropdownMenuItem(
                            value: 'customer', child: Text('Customer')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _relatedType = v!;
                          _relatedId = null;
                        });
                      },
                    ),

                    if (_relatedType != 'None') ...[
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _relatedStream(),
                        builder: (_, snap) {
                          if (!snap.hasData) {
                            return const CircularProgressIndicator();
                          }

                          return DropdownButtonFormField<String>(
                            value: _relatedId,
                            decoration:
                                _inputDecoration('Select $_relatedType'),
                            items: snap.data!.docs.map((d) {
                              return DropdownMenuItem(
                                value: d.id,
                                child: Text(d['name'] ?? 'Unnamed'),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _relatedId = v),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ============ DATE + TIME (UI UNCHANGED) ============
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'No due date selected'
                                  : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                      '${_dueTime != null ? ' at ${_dueTime!.format(context)}' : ''}',
                            ),
                          ),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text('Pick date'),
                          ),
                          TextButton(
                            onPressed: _pickTime,
                            child: const Text('Pick time'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child:
                            Text(_isEdit ? 'Update Task' : 'Add Task'),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
