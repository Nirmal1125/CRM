import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // If using Firebase, initialize here (commented out)
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07142B),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        // add more routes later
        '/dashboard': (context) => const Scaffold(
              body: Center(child: Text('Dashboard (placeholder)')),
            ),
      },
    );
  }
}
