import 'package:easy_localization/easy_localization.dart';

extension StringLocalization on String {
  String get locale => this.tr();
}

extension ImagePathExtension on String {
  String get toSVG => 'asset/svg/$this.svg';
}

extension IntMinutesExtension on String {
  static DateTime startTime = DateTime(2020, 01, 24, 10, 15);

  String get toDateTime => DateFormat('dd.MM.yyyy HH:mm')
      .format(startTime.add(Duration(minutes: int.parse(this))))
      .toString();
}

extension IntDateTimeExtension on int {
  static DateTime startTime = DateTime(2020, 01, 24, 10, 15);

  DateTime get toMclStartDateTime => startTime.add(Duration(minutes: this));
}
