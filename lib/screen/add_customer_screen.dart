import 'package:flutter/material.dart';
import '../services/customer_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final String? customerId;
  final Map<String, dynamic>? initialData;

  const AddCustomerScreen({super.key, this.customerId, this.initialData});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CustomerService();

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _company;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialData?['name'] ?? '');
    _email = TextEditingController(text: widget.initialData?['email'] ?? '');
    _phone = TextEditingController(text: widget.initialData?['phone'] ?? '');
    _company = TextEditingController(
      text: widget.initialData?['company'] ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.customerId == null) {
        await _service.addCustomer(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          company: _company.text.trim(),
        );
      } else {
        await _service.updateCustomer(
          widget.customerId!,
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          company: _company.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
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
        borderSide: const BorderSide(color: Color(0xFFE4E1EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E1EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3F51B5), // Indigo focus color
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customerId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8), // light CRM gray
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Customer',
          style: TextStyle(color: Color(0xFF262626)),
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
              color: const Color(0xFFF8F9FF), // light indigo-tint card
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
                      "Add new customer",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Fill in the customer details below.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6D6D6D)),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _name,
                      decoration: _fieldDecoration(
                        "Customer name",
                        "E.g. John Doe",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(
                        "Email",
                        "customer@example.com",
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration(
                        "Phone",
                        "E.g. +91 98765 43210",
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _company,
                      decoration: _fieldDecoration(
                        "Company",
                        "E.g. Acme Pvt Ltd",
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
                            foregroundColor: const Color(0xFF3F51B5), // Indigo
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5), // Indigo
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
                                    isEdit ? "Save changes" : "Add customer",
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
