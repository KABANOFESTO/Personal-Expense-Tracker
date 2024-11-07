import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/user.dart';

class DatabaseHelper {
  static const _boxName = 'userBox';

  // Define a 32-byte (256-bit) key for AES-256 encryption
  static final _key = encrypt.Key.fromUtf8('32characterslongpassphraseABCD!!'); // Adjusted to 32 characters
  static final _iv = encrypt.IV.fromLength(16); // Initialization vector (16 bytes for AES)
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key)); // AES encryption

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(_boxName);
  }

  Box<User> get _userBox => Hive.box<User>(_boxName);

  // Hashes the password using AES encryption
  String _hashPassword(String password) {
    final encrypted = _encrypter.encrypt(password, iv: _iv);
    return encrypted.base64; // Return the base64-encoded string
  }

  // Verifies the input password against the hashed password
  bool _verifyPassword(String inputPassword, String hashedPassword) {
    return _hashPassword(inputPassword) == hashedPassword;
  }

  // Creates a new user and stores it in the Hive box
  Future<int> createUser(String name, String email, String password) async {
    final emailLowered = email.toLowerCase();

    // Check if user already exists
    if (_userBox.values.any((user) => user.email == emailLowered)) {
      return -1; // Email already exists
    }

    // Create a new user
    final newUser = User(
      name: name,
      email: emailLowered,
      password: _hashPassword(password), // Hash the password before storing
      createdAt: DateTime.now(),
    );

    await _userBox.add(newUser);
    return 1; // User created successfully
  }

  // Retrieve a user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final user = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(name: '', email: '', password: '', createdAt: DateTime.now()), // Use a default User placeholder
      );
      return user.name.isEmpty ? null : user; // Return null if placeholder was returned
    } catch (e) {
      return null; // Handle any exceptions
    }
  }

  // Authenticate user by verifying email and password
  Future<User?> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);

    if (user != null && _verifyPassword(password, user.password)) {
      return user; // User found and password verified
    }
    return null; // User not found or password incorrect
  }
}
