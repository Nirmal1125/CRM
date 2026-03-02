import 'package:crm/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(), // ✅ AUTO REFRESH
      builder: (context, snapshot) {
        final user = snapshot.data;

        final displayName =
            user?.displayName?.isNotEmpty == true ? user!.displayName! : 'User';

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // ================= ACCOUNT =================
                    _section(
                      context,
                      'Account',
                      [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(displayName),
                          subtitle: Text(user?.email ?? 'No email'),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _editProfileDialog(context, user),
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          subtitle: const Text('Send reset email'),
                          onTap: () async {
                            if (user?.email == null) return;
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: user!.email!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Password reset email sent'),
                                ),
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/login');
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= TEAM & ROLES =================
                    _section(
                      context,
                      'Team & Roles',
                      [
                        ListTile(
                          leading: const Icon(Icons.groups),
                          title: const Text('User Role'),
                          subtitle: const Text('Admin'),
                          onTap: () => _infoDialog(
                            context,
                            'User Role',
                            'Role management will be available in a future update.',
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Access Control'),
                          subtitle: const Text('Not enabled'),
                          onTap: () => _infoDialog(
                            context,
                            'Access Control',
                            'Role-based permissions are not enabled yet.',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= NOTIFICATIONS =================
                    _section(
                      context,
                      'Notifications',
                      [
                        SwitchListTile(
                          title: const Text('Push Notifications'),
                          subtitle:
                              const Text('Receive app notifications'),
                          value: settings.pushNotifications,
                          activeColor: theme.colorScheme.primary,
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged:
                              settings.togglePushNotifications,
                        ),
                        SwitchListTile(
                          title: const Text('Task Reminders'),
                          subtitle: const Text(
                              'Remind me about upcoming tasks'),
                          value: settings.taskReminders,
                          activeColor: theme.colorScheme.primary,
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: settings.toggleTaskReminders,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= APPEARANCE =================
                    _section(
                      context,
                      'Appearance',
                      [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Enable dark theme'),
                          value: settings.darkMode,
                          activeColor: theme.colorScheme.primary,
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: settings.toggleDarkMode,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= ABOUT =================
                    _section(
                      context,
                      'About',
                      [
                        ListTile(
                          title: const Text('App Version'),
                          trailing: Text(
                            '1.0.0',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= SECTION =================
  Widget _section(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // ================= EDIT PROFILE =================
  void _editProfileDialog(BuildContext context, User? user) {
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.displayName ?? '');
    final emailCtrl = TextEditingController(text: user.email ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await user.updateDisplayName(nameCtrl.text.trim());

                if (emailCtrl.text.trim() != user.email) {
                  await user.verifyBeforeUpdateEmail(
                    emailCtrl.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Verification email sent. Please verify to update email.',
                      ),
                    ),
                  );
                }

                await user.reload();
                if (context.mounted) Navigator.pop(context);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'For security reasons, please re-login to change email.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= INFO =================
  void _infoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
