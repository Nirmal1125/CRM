import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _status = TextEditingController(text: 'Lead');
  final _city = TextEditingController();
  final _orders = TextEditingController(text: '0');
  final _amountSpent = TextEditingController(text: '0');

  String? _customerId;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || _name.text.isNotEmpty) return;

    _customerId = args['customerId'];
    _name.text = args['name'] ?? '';
    _email.text = args['email'] ?? '';
    _phone.text = args['phone'] ?? '';
    _company.text = args['company'] ?? '';
    _status.text = args['status'] ?? 'Lead';
    _city.text = args['city'] ?? '';
    _orders.text = args['orders'] ?? '0';
    _amountSpent.text = args['amountSpent'] ?? '0';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    _status.dispose();
    _city.dispose();
    _orders.dispose();
    _amountSpent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<CustomerProvider>();

    final data = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'company': _company.text.trim(),
      'status': _status.text.trim(),
      'city': _city.text.trim(),
      'orders': _orders.text.trim(),
      'amountSpent': _amountSpent.text.trim(),
    };

    if (_customerId == null) {
      await provider.addCustomer(data);
    } else {
      await provider.updateCustomer(_customerId!, data);
    }

    if (mounted) Navigator.pop(context, true);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _customerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Customer' : 'Add Customer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration:
                        _fieldDecoration(context, 'Customer name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    decoration: _fieldDecoration(context, 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phone,
                    decoration: _fieldDecoration(context, 'Phone'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _company,
                    decoration: _fieldDecoration(context, 'Company'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _status,
                    decoration: _fieldDecoration(context, 'Status'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _city,
                    decoration: _fieldDecoration(context, 'City'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orders,
                    decoration: _fieldDecoration(context, 'Orders'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountSpent,
                    decoration:
                        _fieldDecoration(context, 'Amount Spent'),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: Text(
                            isEdit ? 'Save changes' : 'Add customer'),
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
