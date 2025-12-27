import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screen/dashboard_ui.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Wait until Firebase auth is initialized
    if (!authProvider.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show dashboard if logged in, otherwise login screen
    if (authProvider.user != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
