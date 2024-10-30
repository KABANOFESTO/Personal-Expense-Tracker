import 'package:flutter/material.dart';
import '../database/expense_db.dart';
import '../models/expense_model.dart';
import 'add_expense_screen.dart';

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
    _futureExpenses = ExpenseDB().getExpenses();
  }

  Future<List<Expense>> _filterExpenses(List<Expense> expenses) async {
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

    if (_sortBy == 'date') {
      filtered.sort((a, b) {
        return _sortOrder == 'desc' ? b.date.compareTo(a.date) : a.date.compareTo(b.date);
      });
    } else if (_sortBy == 'amount') {
      filtered.sort((a, b) {
        return _sortOrder == 'desc' ? b.amount.compareTo(a.amount) : a.amount.compareTo(b.amount);
      });
    }

    return filtered;
  }

  Future<void> _deleteExpense(int id) async {
    await ExpenseDB().deleteExpense(id);
    setState(() {
      _futureExpenses = ExpenseDB().getExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Expense List', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              ).then((_) {
                setState(() {
                  _futureExpenses = ExpenseDB().getExpenses(); // Refresh expenses after adding
                });
              });
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

          return Column(
            children: [
              // Filters
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
              // Expenses List
              Expanded(
                child: FutureBuilder<List<Expense>>(
                  future: _filterExpenses(expenses),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final filteredExpenses = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text('${expense.description} - \$${expense.amount}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${expense.category} on ${expense.date}', style: TextStyle(color: Colors.grey[600])),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExpense(expense.id!),
                            ),
                          ),
                        );
                      },
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
      dropdownColor: Colors.teal.shade100,
      items: items.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category, style: TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
    );
  }
}
