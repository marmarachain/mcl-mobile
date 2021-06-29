import 'package:hive/hive.dart';

part 'chain.g.dart';

@HiveType(typeId: 1)
class Chain {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String address;
  @HiveField(3)
  final int port;
  @HiveField(4)
  Map<String, dynamic>? getinfo;
  @HiveField(5)
  Map<String, dynamic>? marmarainfo;
  @HiveField(6)
  DateTime? refreshTime;
  @HiveField(7)
  Map<String, dynamic>? getGenerate;
  @HiveField(8)
  Map<String, dynamic>? marmaraholderloops;
  @HiveField(9)
  Map<String, dynamic>? marmaraholderloopsdetail;

  Chain({
    required this.title,
    required this.username,
    required this.address,
    required this.port,
    this.getinfo,
    this.marmarainfo,
    this.refreshTime,
    this.getGenerate,
  });
}
