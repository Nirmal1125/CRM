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
  final _sourceOptions = const ['Website', 'Call', 'Referral', 'Email', 'Other'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialData?['name'] ?? '');
    _company = TextEditingController(text: widget.initialData?['company'] ?? '');
    _email = TextEditingController(text: widget.initialData?['email'] ?? '');
    _phone = TextEditingController(text: widget.initialData?['phone'] ?? '');
    _assignedTo =
        TextEditingController(text: widget.initialData?['assignedTo'] ?? '');
    _notes = TextEditingController(text: widget.initialData?['notes'] ?? '');
    _tags = TextEditingController(
      text: (widget.initialData?['tags'] as List?)?.join(', ') ?? '',
    );
    _score = TextEditingController(
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

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF5F5F5F)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E1EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E1EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.4),
      ),
    );
  }

  Widget _dropdownField({
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
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final tags = _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final score =
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
          tags: tags,
          score: score,
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
          tags: tags,
          score: score,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.leadId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEdit ? 'Edit Lead' : 'Add Lead',
          style: const TextStyle(color: Color(0xFF262626)),
        ),
        foregroundColor: const Color(0xFF262626),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF8F9FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add new lead",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 28),

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

                    _dropdownField(
                      label: 'Status',
                      value: _status,
                      options: _statusOptions,
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 16),

                    _dropdownField(
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

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child:
                              Text(isEdit ? 'Save changes' : 'Add lead'),
                        ),
                      ],
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
