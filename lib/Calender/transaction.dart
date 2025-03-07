import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {

  @HiveField(0)
  double amount;

  @HiveField(1)
  String category;

  @HiveField(2)
  String accountType;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String type;

  Transaction({
    required this.amount,
    required this.category,
    required this.accountType,
    required this.date,
    required this.type,
  });
}
