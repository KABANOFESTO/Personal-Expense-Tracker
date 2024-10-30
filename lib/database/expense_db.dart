import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class ExpenseDB {
  static final ExpenseDB _instance = ExpenseDB._internal();
  Box<Expense>? _expenseBox;

  factory ExpenseDB() => _instance;

  ExpenseDB._internal();

  Future<void> init() async {
    // Initialize Hive and open a box for expenses
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter()); // Register the adapter for Expense
    _expenseBox = await Hive.openBox<Expense>('expenses');
  }

  Future<List<Expense>> getExpenses() async {
    if (_expenseBox == null) return [];

    return _expenseBox!.values.toList(); // Return a list of expenses
  }

  Future<void> addExpense(Expense expense) async {
    if (_expenseBox != null) {
      await _expenseBox!.add(expense); // Add expense to the box
    }
  }

  Future<void> deleteExpense(int index) async {
    if (_expenseBox != null) {
      await _expenseBox!.deleteAt(index); // Delete expense at the given index
    }
  }
}
