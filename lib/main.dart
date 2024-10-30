import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For web storage
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_passord_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/expense_list_screen.dart';
import 'database/database_helper.dart';

Future<void> main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific setup
  if (kIsWeb) {
    // For web, we can skip sqflite initialization
    print('Running on web; skipping sqflite initialization.');
  } else {
    sqfliteFfiInit(); // Initialize sqflite for all non-web platforms
    databaseFactory = databaseFactoryFfi;
  }

  try {
    if (kIsWeb) {
      // For web, just initialize shared preferences
      final prefs = await SharedPreferences.getInstance();
      print('Shared Preferences initialized successfully for web');
    } else {
      // For mobile platforms, initialize the database
      await DatabaseHelper.instance.database;
      print('Database initialized successfully');
    }
  } catch (e) {
    print('Storage initialization error: $e');
    // Handle initialization error appropriately
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses Tracker',
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/dashboard': (context) => Dashboard(),
        '/add_expense': (context) => AddExpenseScreen(),
        '/expense_list': (context) => ExpenseListScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
