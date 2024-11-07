import 'package:hive/hive.dart';

part 'user.g.dart'; // Make sure to generate this file

@HiveType(typeId: 1) // Unique type ID for each Hive model
class User extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });
}
