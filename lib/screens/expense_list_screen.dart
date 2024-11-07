import 'package:flutter/material.dart';
import '../database/expense_db.dart';
import '../models/expense_model.dart';
import 'add_expense_screen.dart';
import 'dart:io';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late Future<List<Expense>> _futureExpenses;
  String _selectedCategory = 'all';
  String _selectedMonth = 'all';
  String _sortBy = 'date';
  String _sortOrder = 'desc';
  List<String> _categories = ['all', 'Food', 'Transport', 'Utilities', 'Others'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _futureExpenses = ExpenseDB().getExpenses();
    });
    _futureExpenses.then((expenses) {
      print("Loaded expenses: $expenses"); // Debugging line to confirm loading
    }).catchError((error) {
      print("Error loading expenses: $error"); // Debugging line for errors
    });
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    var filtered = expenses;

    if (_selectedCategory != 'all') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }

    if (_selectedMonth != 'all') {
      filtered = filtered.where((e) {
        final date = e.date;
        return '${date.year}-${date.month.toString().padLeft(2, '0')}' == _selectedMonth;
      }).toList();
    }

    filtered.sort((a, b) {
      if (_sortBy == 'date') {
        return _sortOrder == 'desc' ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
      } else if (_sortBy == 'amount') {
        return _sortOrder == 'desc' ? b.amount.compareTo(a.amount) : a.amount.compareTo(b.amount);
      }
      return 0;
    });

    print("Filtered expenses: $filtered"); // Debugging line for filtered data
    return filtered;
  }

  Future<void> _deleteExpense(int id) async {
    await ExpenseDB().deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              ).then((_) => _loadExpenses());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _futureExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final expenses = snapshot.data ?? [];
          final filteredExpenses = _filterExpenses(expenses);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.teal.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDropdownButton(_selectedCategory, _categories, (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    }),
                    _buildDropdownButton(_selectedMonth, ['all', '2024-01', '2024-02'], (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    }),
                    _buildDropdownButton(_sortBy, ['date', 'amount'], (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    }),
                    _buildDropdownButton(_sortOrder, ['desc', 'asc'], (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    }),
                  ],
                ),
              ),
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(child: Text('No expenses found'))
                    : ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: expense.imagePath != null && expense.imagePath!.isNotEmpty
                                  ? Image.file(
                                      File(expense.imagePath!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.receipt, size: 50), // Placeholder icon if no image
                              title: Text('${expense.description} - \$${expense.amount}'),
                              subtitle: Text('${expense.category} on ${expense.date}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteExpense(expense.id!),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  DropdownButton<String> _buildDropdownButton(String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
