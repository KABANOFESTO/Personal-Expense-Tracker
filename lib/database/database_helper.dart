import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "UserAuth.db";
  static const _databaseVersion = 1;
  static const table = 'users';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnCreatedAt = 'created_at';

  static final _key = encrypt.Key.fromUtf8('32characterslongpassphrase!!');
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory documentsDirectory;
    try {
      documentsDirectory = await getApplicationDocumentsDirectory();
    } catch (e) {
      throw Exception('Failed to get application documents directory: $e');
    }

    final path = join(documentsDirectory.path, _databaseName);

    try {
      await Directory(documentsDirectory.path).create(recursive: true);
    } catch (e) {
      print('Error creating directory: $e');
      // Continue anyway as directory might already exist
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onOpen: (db) async {
        print('Database opened successfully');
      },
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    try {
      await db.execute('''  
        CREATE TABLE $table (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnEmail TEXT NOT NULL UNIQUE,
          $columnPassword TEXT NOT NULL,
          $columnCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      throw e; // Rethrow to handle it in the calling function
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        table,
        where: '$columnEmail = ?',
        whereArgs: [email.toLowerCase()],
      );

      return results.isEmpty ? null : results.first;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  String _hashPassword(String password) {
    try {
      return _encrypter.encrypt(password, iv: _iv).base64;
    } catch (e) {
      print('Error hashing password: $e');
      throw Exception('Failed to hash password');
    }
  }

  bool _verifyPassword(String inputPassword, String hashedPassword) {
    try {
      return _hashPassword(inputPassword) == hashedPassword;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  Future<int> createUser(String name, String email, String password) async {
    try {
      final db = await database;

      // Check if email already exists
      final List<Map<String, dynamic>> emailCheck = await db.query(
        table,
        where: '$columnEmail = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (emailCheck.isNotEmpty) {
        return -1; // Email already exists
      }

      final Map<String, dynamic> row = {
        columnName: name,
        columnEmail: email.toLowerCase(),
        columnPassword: _hashPassword(password),
      };

      return await db.insert(table, row);
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);

      if (user == null) {
        return null; // User not found
      }

      return _verifyPassword(password, user[columnPassword]) ? user : null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }
}

// Main Application Entry
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database; // Await the database initialization
    runApp(MyApp());
  } catch (e) {
    print('Error initializing application: $e');
    // Handle initialization error appropriately
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Auth Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> getUser() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.getUserByEmail('example@email.com');
      if (user != null) {
        print('User found: $user');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error getting user: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Auth Demo'),
      ),
      body: Center(
        child: Text('Check console for user data'),
      ),
    );
  }
}
