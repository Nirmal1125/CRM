// lib/main.dart
import 'package:crm/firebase_options.dart';
import 'package:crm/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/leads_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase initialization
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
    return MaterialApp(
      title: 'CRM',
      debugShowCheckedModeBanner: false,
      // Force light theme as requested
      theme: _buildLightTheme(),
      darkTheme: _buildLightTheme(),
      themeMode: ThemeMode.light,

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // Customer screen - now constructed without passing null
        '/customers': (context) => const CustomerListScreen(),

        '/leads': (context) => const LeadsListScreen(),
      },
    );
  }
}