// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/leads_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
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
    final ThemeData light = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.indigo,
      useMaterial3: true,
      cardColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
          .copyWith(secondary: Colors.indigoAccent),
      textTheme: ThemeData.light().textTheme,
      iconTheme: const IconThemeData(color: Colors.black87),
    );

    final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF07142B),
      primaryColor: Colors.indigo,
      useMaterial3: true,
      cardColor: const Color(0xFF121217),
      textTheme: ThemeData.dark().textTheme,
      iconTheme: const IconThemeData(color: Colors.white70),
    );

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
