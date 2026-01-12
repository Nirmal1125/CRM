import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/lead_provider.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({Key? key}) : super(key: key);

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _assignedTo = TextEditingController();
  final _notes = TextEditingController();
  final _tags = TextEditingController();
  final _score = TextEditingController();

  String _status = 'New';
  String _source = 'Website';
  String? _leadId;
  bool _saving = false;

  final _statusOptions = const ['New', 'In Progress', 'Won', 'Lost'];
  final _sourceOptions = const ['Website', 'Call', 'Referral', 'Email', 'Other'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || _name.text.isNotEmpty) return;

    _leadId = args['leadId'];
    _name.text = args['name'] ?? '';
    _company.text = args['company'] ?? '';
    _email.text = args['email'] ?? '';
    _phone.text = args['phone'] ?? '';
    _assignedTo.text = args['assignedTo'] ?? '';
    _notes.text = args['notes'] ?? '';
    _tags.text = (args['tags'] as List?)?.join(', ') ?? '';
    _score.text = args['score']?.toString() ?? '';
    _status = args['status'] ?? 'New';
    _source = args['source'] ?? 'Website';
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
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 1.6),
      ),
    );
  }

  Widget _dropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _fieldDecoration(context, label),
      items: options
          .map(
            (e) => DropdownMenuItem(value: e, child: Text(e)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<LeadProvider>();

    final data = {
      'name': _name.text.trim(),
      'company': _company.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'status': _status,
      'source': _source,
      'assignedTo': _assignedTo.text.trim(),
      'notes': _notes.text.trim(),
      'tags': _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'score': int.tryParse(_score.text),
    };

    if (_leadId == null) {
      await provider.addLead(data);
    } else {
      await provider.updateLead(_leadId!, data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_leadId == null ? 'Add Lead' : 'Edit Lead'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                    _leadId == null ? 'Add new lead' : 'Edit lead',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _name,
                    decoration:
                        _fieldDecoration(context, 'Lead title'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _company,
                    decoration:
                        _fieldDecoration(context, 'Company'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _email,
                    decoration:
                        _fieldDecoration(context, 'Email'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phone,
                    decoration:
                        _fieldDecoration(context, 'Phone'),
                  ),
                  const SizedBox(height: 16),

                  _dropdown(
                    context: context,
                    label: 'Status',
                    value: _status,
                    options: _statusOptions,
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 16),

                  _dropdown(
                    context: context,
                    label: 'Source',
                    value: _source,
                    options: _sourceOptions,
                    onChanged: (v) => setState(() => _source = v!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _assignedTo,
                    decoration:
                        _fieldDecoration(context, 'Assigned to'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _score,
                    keyboardType: TextInputType.number,
                    decoration:
                        _fieldDecoration(context, 'Score'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tags,
                    decoration:
                        _fieldDecoration(context, 'Tags'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration:
                        _fieldDecoration(context, 'Notes'),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(
                          _leadId == null
                              ? 'Add lead'
                              : 'Save changes',
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
    );
  }
}
