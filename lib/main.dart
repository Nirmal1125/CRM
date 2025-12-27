// lib/main.dart
import 'package:crm/auth_wrapper.dart';
import 'package:crm/firebase_options.dart';
import 'package:crm/provider/auth_provider.dart';
import 'package:crm/screen/add_customer_screen.dart';
import 'package:crm/screen/add_lead_screen.dart';
import 'package:crm/screen/dashboard_ui.dart';
import 'package:crm/screens/login_screen.dart';
import 'package:crm/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase initialization
await auth.FirebaseAuth.instance.setPersistence(auth.Persistence.LOCAL);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ------------------------------
  // LIGHT THEME
  // ------------------------------
  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      primaryColor: Colors.indigo,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
          .copyWith(secondary: Colors.indigoAccent),
      textTheme: base.textTheme,
      iconTheme: const IconThemeData(color: Colors.black87),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) {
        final authProvider = AuthProvider(); 
        return authProvider;
      },
    ),
  ],
  child: MaterialApp(
    title: 'CRM',
    debugShowCheckedModeBanner: false,
    theme: _buildLightTheme(),
    darkTheme: _buildLightTheme(),
    themeMode: ThemeMode.light,
    home: const AuthWrapper(),
     routes: {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/signup': (context) => const SignUpScreen(),
    '/add-customer': (context) => const AddCustomerScreen(),
    '/add-lead': (context) => const AddLeadScreen(),
  },
  ),
);

  }
}