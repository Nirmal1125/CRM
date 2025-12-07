// lib/screens/add_lead_screen.dart
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

  late TextEditingController _title;
  late TextEditingController _value;
  late TextEditingController _customerId;

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
    _title = TextEditingController(text: widget.initialData?['title'] ?? '');
    _value = TextEditingController(
      text: widget.initialData?['value']?.toString() ?? '',
    );
    _customerId = TextEditingController(
      text: widget.initialData?['customerId'] ?? '',
    );

    _status = widget.initialData?['status'] ?? 'New';
    _source = widget.initialData?['source'] ?? 'Website';
  }

  @override
  void dispose() {
    _title.dispose();
    _value.dispose();
    _customerId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final double? parsedValue =
          _value.text.trim().isEmpty
              ? null
              : double.tryParse(_value.text.trim());

      if (widget.leadId == null) {
        await _service.addLead(
          title: _title.text.trim(),
          status: _status,
          source: _source,
          customerId: _customerId.text.trim(),
          value: parsedValue,
        );
      } else {
        await _service.updateLead(
          widget.leadId!,
          title: _title.text.trim(),
          status: _status,
          source: _source,
          customerId: _customerId.text.trim(),
          value: parsedValue,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save lead: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF5F5F5F)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 244, 243, 245)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E1EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
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
                        DropdownMenuItem<String>(value: opt, child: Text(opt)),
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
              color: const Color(0xFFF8F9FF), // light indigo tint
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
                    Text(
                      isEdit ? "Edit lead" : "Add new lead",
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Fill in the lead details below.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6D6D6D)),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _title,
                      decoration: _fieldDecoration(
                        "Lead title",
                        "E.g. Website enquiry",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Enter title" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: "Status",
                      value: _status,
                      options: _statusOptions,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: "Source",
                      value: _source,
                      options: _sourceOptions,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _source = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _value,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        "Value (optional)",
                        "E.g. 50000",
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _customerId,
                      decoration: _fieldDecoration(
                        "Customer ID (optional)",
                        "Can link to a customer later",
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF3F51B5),
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    isEdit ? "Save changes" : "Add lead",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
