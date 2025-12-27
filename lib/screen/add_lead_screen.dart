import 'package:flutter/material.dart';
import '../services/lead_service.dart';

class AddLeadScreen extends StatefulWidget {
  final String? leadId;
  final Map<String, dynamic>? initialData;

  const AddLeadScreen({super.key, this.leadId, this.initialData});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = LeadService();

  late TextEditingController _name;
  late TextEditingController _company;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _assignedTo;
  late TextEditingController _notes;
  late TextEditingController _tags;
  late TextEditingController _score;

  String _status = 'New';
  String _source = 'Website';

  bool _isSaving = false;

  final _statusOptions = const ['New', 'In Progress', 'Won', 'Lost'];
  final _sourceOptions = const [
    'Website',
    'Call',
    'Referral',
    'Email',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialData?['name'] ?? '');
    _company =
        TextEditingController(text: widget.initialData?['company'] ?? '');
    _email =
        TextEditingController(text: widget.initialData?['email'] ?? '');
    _phone =
        TextEditingController(text: widget.initialData?['phone'] ?? '');
    _assignedTo =
        TextEditingController(text: widget.initialData?['assignedTo'] ?? '');
    _notes =
        TextEditingController(text: widget.initialData?['notes'] ?? '');
    _tags =
        TextEditingController(
          text: (widget.initialData?['tags'] as List?)
                  ?.join(', ') ??
              '',
        );
    _score =
        TextEditingController(
          text: widget.initialData?['score']?.toString() ?? '',
        );

    _status = widget.initialData?['status'] ?? 'New';
    _source = widget.initialData?['source'] ?? 'Website';
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _email.dispose();
    _phone.dispose();
    _assignedTo.dispose();
    _notes.dispose();
    _tags.dispose();
    _score.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tagsList =
          _tags.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final scoreValue =
          _score.text.isNotEmpty ? int.tryParse(_score.text) : null;

      if (widget.leadId == null) {
        await _service.addLead(
          name: _name.text.trim(),
          company: _company.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          status: _status,
          source: _source,
          assignedTo: _assignedTo.text.trim(),
          notes: _notes.text.trim(),
          tags: tagsList,
          score: scoreValue,
        );
      } else {
        await _service.updateLead(
          widget.leadId!,
          name: _name.text.trim(),
          company: _company.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          status: _status,
          source: _source,
          assignedTo: _assignedTo.text.trim(),
          notes: _notes.text.trim(),
          tags: tagsList,
          score: scoreValue,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save lead: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: _fieldDecoration(label, ''),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items:
              options
                  .map(
                    (opt) =>
                        DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt),
                        ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.leadId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Lead' : 'Add Lead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration:
                    _fieldDecoration('Lead title', 'Website enquiry'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _company,
                decoration:
                    _fieldDecoration('Company', 'Acme Pvt Ltd'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _email,
                decoration:
                    _fieldDecoration('Email', 'lead@example.com'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phone,
                decoration:
                    _fieldDecoration('Phone', '+91 98765 43210'),
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Status',
                value: _status,
                options: _statusOptions,
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Source',
                value: _source,
                options: _sourceOptions,
                onChanged: (v) => setState(() => _source = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _assignedTo,
                decoration:
                    _fieldDecoration('Assigned to', 'Sales agent'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _score,
                keyboardType: TextInputType.number,
                decoration:
                    _fieldDecoration('Score', 'Optional'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tags,
                decoration:
                    _fieldDecoration('Tags', 'hot, priority'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration:
                    _fieldDecoration('Notes', 'Additional details'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(isEdit ? 'Save changes' : 'Add lead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
