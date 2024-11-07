import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String category;

  @HiveField(2)
  String description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? imagePath; // New field to store image path

  Expense({
    this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.imagePath,
  });
}
