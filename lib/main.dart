// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_list_screen.dart';
// NOTE: add_customer_screen.dart intentionally NOT imported/used here
// (you removed that file)

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
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
      theme: light,
      darkTheme: dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // If you want the app to start on the Customers page for testing,
      // change initialRoute to '/customers'. For normal flow keep it '/'.
      initialRoute: '/customers', // change to '/customers' to skip login during dev/testing

      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // Pass theme toggle into customers screen so header can toggle theme
        '/customers': (context) => CustomerListScreen(
              onToggleTheme: _toggleTheme,
              isDark: _isDark,
            ),

        // '/add-customer' route intentionally removed because AddCustomerScreen file was deleted.
        // CustomerListScreen safely falls back to an informational dialog when this route is absent.
      },
    );
  }
}
