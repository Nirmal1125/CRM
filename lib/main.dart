// lib/main.dart
import 'package:crm/auth_wrapper.dart';
import 'package:crm/firebase_options.dart';
import 'package:crm/provider/auth_provider.dart';
import 'package:crm/provider/customer_provider.dart';
import 'package:crm/provider/dashboard_provider.dart';
import 'package:crm/provider/lead_provider.dart';
import 'package:crm/provider/settings_provider.dart'; // ✅ ADD
import 'package:crm/provider/task_provider.dart';
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
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F), // YouTube dark
    cardColor: const Color(0xFF1C1C1E),
    dividerColor: Colors.white12,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5B6CFF),
      secondary: Color(0xFF5B6CFF),
      background: Color(0xFF0F0F0F),
      surface: Color(0xFF1C1C1E),
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0F0F),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    iconTheme: const IconThemeData(color: Colors.white70),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Color(0xFF5B6CFF)),
      trackColor: WidgetStateProperty.all(Color(0xFF5B6CFF).withOpacity(.4)),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => TaskProvider()),
    ChangeNotifierProvider(create: (_) => LeadProvider()),
    ChangeNotifierProvider(create: (_) => CustomerProvider()),

    ChangeNotifierProxyProvider3<
        TaskProvider,
        LeadProvider,
        CustomerProvider,
        DashboardProvider>(
      create: (context) => DashboardProvider(
        taskProvider: context.read<TaskProvider>(),
        leadProvider: context.read<LeadProvider>(),
        customerProvider: context.read<CustomerProvider>(),
      ),
      update: (_, task, lead, customer, __) =>
          DashboardProvider(
            taskProvider: task,
            leadProvider: lead,
            customerProvider: customer,
          ),
    ),
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
