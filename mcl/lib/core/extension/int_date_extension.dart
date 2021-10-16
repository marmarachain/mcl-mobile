import 'package:intl/intl.dart';

extension IntDateTimeCustomExtension on int {
  static DateTime startTime = DateTime(1970, 01, 01, 00, 00);

  // DateTime get toConvertDateTime => startTime.add(Duration(seconds: this));
  // String get toConvertDateTime =>
  //     startTime.add(Duration(seconds: this)).toString().substring(0, 16);
  String get toConvertDateTime => DateFormat('dd.MM.yyyy HH:mm')
      .format(startTime.add(Duration(seconds: this)))
      .toString();
}
