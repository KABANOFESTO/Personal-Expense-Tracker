import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static const String USERS_KEY = 'users';
  static const String LOANS_KEY = 'loans';
  static const String BUY_TRANSACTIONS_KEY = 'buy_transactions';
  static const String SELL_TRANSACTIONS_KEY = 'sell_transactions';
  static const String PRODUCTS_KEY = 'products'; // Key for products

  late SharedPreferences _prefs;

  Future<void> initDB() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User-related methods
  Future<bool> insertUser(Map<String, dynamic> user) async {
    List<String> users = _prefs.getStringList(USERS_KEY) ?? [];

    if (users.any((u) => json.decode(u)['email'] == user['email'])) {
      return false; // User already exists
    }

    users.add(json.encode(user));
    return await _prefs.setStringList(USERS_KEY, users);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    List<String> users = _prefs.getStringList(USERS_KEY) ?? [];

    try {
      return users
          .map((userString) => json.decode(userString) as Map<String, dynamic>)
          .firstWhere(
            (user) => user['email'] == email && user['password'] == password,
          );
    } catch (e) {
      return null; // User not found
    }
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    List<String> users = _prefs.getStringList(USERS_KEY) ?? [];

    try {
      return users
          .map((userString) => json.decode(userString) as Map<String, dynamic>)
          .firstWhere(
            (user) => user['email'] == email,
          );
    } catch (e) {
      return null; // User not found
    }
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    List<String> users = _prefs.getStringList(USERS_KEY) ?? [];

    int index = users.indexWhere((userString) {
      Map<String, dynamic> user = json.decode(userString);
      return user['email'] == email;
    });

    if (index != -1) {
      Map<String, dynamic> user = json.decode(users[index]);
      user['password'] = newPassword;
      users[index] = json.encode(user);
      return await _prefs.setStringList(USERS_KEY, users);
    }
    return false; // User not found
  }

  // Product-related methods
  Future<bool> insertProduct(Map<String, dynamic> product) async {
    List<String> products = _prefs.getStringList(PRODUCTS_KEY) ?? [];
    products.add(json.encode(product));
    return await _prefs.setStringList(PRODUCTS_KEY, products);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    List<String> products = _prefs.getStringList(PRODUCTS_KEY) ?? [];
    return products.map((productString) => json.decode(productString) as Map<String, dynamic>).toList();
  }

  // Loan-related methods
  Future<bool> insertLoan(Map<String, dynamic> loan) async {
    List<String> loans = _prefs.getStringList(LOANS_KEY) ?? [];
    loans.add(json.encode(loan));
    return await _prefs.setStringList(LOANS_KEY, loans);
  }

  Future<List<Map<String, dynamic>>> getLoans() async {
    List<String> loans = _prefs.getStringList(LOANS_KEY) ?? [];
    return loans.map<Map<String, dynamic>>((loanString) => json.decode(loanString) as Map<String, dynamic>).toList();
  }

  Future<bool> deleteLoan(String customerName) async {
    List<String> loans = _prefs.getStringList(LOANS_KEY) ?? [];
    loans.removeWhere((loanString) => json.decode(loanString)['customer_name'] == customerName);
    return await _prefs.setStringList(LOANS_KEY, loans);
  }

  // Transaction-related methods
  Future<bool> _insertTransaction(String key, Map<String, dynamic> transaction) async {
    List<String> transactions = _prefs.getStringList(key) ?? [];
    transactions.add(json.encode(transaction));
    return await _prefs.setStringList(key, transactions);
  }

  Future<List<Map<String, dynamic>>> _getTransactions(String key) async {
    List<String> transactions = _prefs.getStringList(key) ?? [];
    return transactions.map((transactionString) => json.decode(transactionString) as Map<String, dynamic>).toList();
  }

  // Buy-related methods
  Future<bool> insertBuyTransaction(Map<String, dynamic> transaction) async {
    return _insertTransaction(BUY_TRANSACTIONS_KEY, transaction);
  }

  Future<List<Map<String, dynamic>>> getBuyTransactions() async {
    return _getTransactions(BUY_TRANSACTIONS_KEY);
  }

  // Sell-related methods
  Future<bool> insertSellTransaction(Map<String, dynamic> transaction) async {
    return _insertTransaction(SELL_TRANSACTIONS_KEY, transaction);
  }

  Future<List<Map<String, dynamic>>> getSellTransactions() async {
    return _getTransactions(SELL_TRANSACTIONS_KEY);
  }
}
