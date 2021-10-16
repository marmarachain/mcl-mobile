import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  final String address;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String txid;
  @HiveField(4)
  final int blocktime;
  @HiveField(5)
  final int timereceived;

  Transaction({
    required this.address,
    required this.category,
    required this.amount,
    required this.txid,
    required this.blocktime,
    required this.timereceived,
  });
}
