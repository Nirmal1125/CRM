// lib/main.dart
import 'package:crm/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialization
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'CRM',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

        initialRoute: '/customers', // dev testing

        routes: {
          '/': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/customers': (context) => CustomerListScreen(
                onToggleTheme: _toggleTheme,
                isDark: _isDark,
              ),
        },
      ),
    );
  }
}
