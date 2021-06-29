import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 2)
class Person {
  @HiveField(0)
  final String isim;
  @HiveField(1)
  final String cuzdanAdresi;
  @HiveField(2)
  final String pubKey;

  Person({
    required this.isim,
    required this.cuzdanAdresi,
    required this.pubKey,
  });
}
