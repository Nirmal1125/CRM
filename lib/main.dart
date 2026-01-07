// lib/main.dart
import 'package:crm/auth_wrapper.dart';
import 'package:crm/firebase_options.dart';
import 'package:crm/provider/auth_provider.dart';
import 'package:crm/provider/settings_provider.dart'; // ✅ ADD
import 'package:crm/screen/add_customer_screen.dart';
import 'package:crm/screen/add_lead_screen.dart';
import 'package:crm/screen/add_task_screen.dart';
import 'package:crm/screen/dashboard_ui.dart';
import 'package:crm/screens/login_screen.dart';
import 'package:crm/screens/signup_screen.dart';
import 'package:crm/services/local_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await auth.FirebaseAuth.instance.setPersistence(
      auth.Persistence.LOCAL,
    );
  }

  await LocalNotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      primaryColor: Colors.indigo,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
          .copyWith(secondary: Colors.indigoAccent),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
      colorScheme: const ColorScheme.dark(
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // ✅ ADD
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'CRM',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode:
                settings.darkMode ? ThemeMode.dark : ThemeMode.light, // ✅
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/add-customer': (context) => const AddCustomerScreen(),
              '/add-lead': (context) => const AddLeadScreen(),
              '/add-task': (context) => const AddTaskScreen(),
            },
          );
        },
      ),
    );
  }
}
