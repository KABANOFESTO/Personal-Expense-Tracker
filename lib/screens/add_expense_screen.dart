import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'dart:io'; // Import for file handling
import '../database/expense_db.dart';
import '../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Food';
  String _description = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  File? _image; // Variable to store the selected image
  final ImagePicker _picker = ImagePicker();

  void _addExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Expense newExpense = Expense(
        category: _category,
        description: _description,
        amount: _amount,
        date: _date,
        imagePath: _image?.path, // Store the image path if available
      );
      await ExpenseDB().addExpense(newExpense);
      print("Expense added: $newExpense"); // Debugging line

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully!')),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Food', 'Transport', 'Utilities', 'Others'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter an amount';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                    onSaved: (value) => _amount = double.parse(value!),
                  ),
                  SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date: ${DateFormat.yMd().format(_date)}'),
                  ),
                  SizedBox(height: 20),
                  _image == null
                      ? Text("No image selected")
                      : Image.file(_image!, height: 100), // Display the selected image
                  ElevatedButton(
                    onPressed: _pickImage, // Button to pick an image
                    child: Text('Upload Receipt Image'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addExpense,
                    child: Text('Add Expense'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
