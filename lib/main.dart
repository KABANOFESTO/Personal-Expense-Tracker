import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_passord_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/expense_list_screen.dart';
import 'models/user.dart';
import 'models/expense_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options if on the web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDRZ61eqEE5P0q_-gO0DWntjyinZrL9TdM",
        authDomain: "ExpenseTracker.Rw",
        projectId: "expense-tracker-5fc75",
        storageBucket: "expense-tracker-5fc75.firebasestorage.app",
        messagingSenderId: "383256227291",
        appId: "1:383256227291:android:4dff77b680ab2b53fd4bfe",
        measurementId: "466041941",
      ),
    );
  } else {
    await Firebase.initializeApp(); // For non-web platforms
  }

  // Initialize Hive for web or mobile
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  } else {
    await Hive.initFlutter();
  }

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  // Open the necessary Hive boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Expense>('expenseBox');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses Tracker',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/dashboard': (context) => Dashboard(toggleTheme: _toggleTheme),
        '/add_expense': (context) => AddExpenseScreen(),
        '/expense_list': (context) => ExpenseListScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
    );
  }
}