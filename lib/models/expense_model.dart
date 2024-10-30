// expense_model.dart
class Expense {
  int? id;
  String category;
  String description;
  double amount;
  DateTime date; // Keep as DateTime for internal use

  Expense({
    this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  // Method to convert the Expense object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(), // Convert DateTime to String
    };
  }

  // Method to create an Expense object from a Map
  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Convert String to DateTime
    );
  }
}
