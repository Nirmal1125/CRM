import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _email = '', _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,

      // Pure iOS navigation bar (this fixes the broken "Cancel")
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'New Customer',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF007AFF)), // exact iOS blue
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // TODO: Firebase save here
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE5E5EA),
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Form card
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: CupertinoColors.systemBackground,
                child: Column(
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text(
                        ' Name',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      placeholder: 'John Appleseed',
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) => _name = v!.trim(),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Divider(height: 0.5),
                    CupertinoTextFormFieldRow(
                      prefix: const Text(
                        ' Email',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      placeholder: 'john@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (v) =>
                              v!.isEmpty || !v.contains('@')
                                  ? 'Invalid email'
                                  : null,
                      onSaved: (v) => _email = v!.trim(),
                    ),
                    const Divider(height: 0.5),
                    CupertinoTextFormFieldRow(
                      prefix: const Text(
                        ' Phone',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      placeholder: '+1 (555) 123-4567',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) => _phone = v!.trim(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Real iCloud blue button
            SizedBox(
              height: 50,
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF007AFF), // exact Apple blue
                child: const Text(
                  'Save Customer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
