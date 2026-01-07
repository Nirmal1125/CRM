import 'package:crm/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _left(context, user)),
                      const SizedBox(width: 24),
                      Expanded(child: _right(context, settings)),
                    ],
                  )
                : Column(
                    children: [
                      _left(context, user),
                      const SizedBox(height: 24),
                      _right(context, settings),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ================= LEFT =================

  Widget _left(BuildContext context, User? user) {
    return Column(
      children: [
        _section(
          'Account',
          [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: Text(user?.email ?? 'No email'),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              subtitle: const Text('Send reset email'),
              onTap: () async {
                if (user?.email == null) return;
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: user!.email!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _section(
          'Team & Roles',
          [
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('User Role'),
              subtitle: const Text('Admin'),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Access Control'),
              subtitle: const Text('Role-based permissions'),
            ),
          ],
        ),
      ],
    );
  }

  // ================= RIGHT =================

  Widget _right(BuildContext context, SettingsProvider settings) {
    return Column(
      children: [
        _section(
          'Notifications',
          [
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: settings.pushNotifications,
              onChanged: settings.togglePushNotifications,
            ),
            SwitchListTile(
              title: const Text('Task Reminders'),
              value: settings.taskReminders,
              onChanged: settings.toggleTaskReminders,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _section(
          'Appearance',
          [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings.darkMode,
              onChanged: settings.toggleDarkMode,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _section(
          'About',
          const [
            ListTile(title: Text('App Version'), trailing: Text('1.0.0')),
            ListTile(title: Text('Platform'), trailing: Text('Flutter')),
          ],
        ),
      ],
    );
  }

  // ================= UI =================

  Widget _section(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
