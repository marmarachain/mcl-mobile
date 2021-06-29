import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

enum MclLoopSortValues { NAME, AMOUNT, MATURES }
enum MclLoopSortValuesType { ASC, DSC }

extension MclLoopSortValuesExtension on MclLoopSortValues {
  String get rawValue {
    switch (this) {
      case MclLoopSortValues.NAME:
        return '${LocaleKeys.credit_endorser_filter_name.locale}';
      case MclLoopSortValues.AMOUNT:
        return '${LocaleKeys.credit_endorser_filter_amount.locale}';
      case MclLoopSortValues.MATURES:
        return '${LocaleKeys.credit_endorser_filter_matures.locale}';
    }
  }
}

extension MclLoopSortValuesTypeExtension on MclLoopSortValuesType {
  int get rawValue {
    switch (this) {
      case MclLoopSortValuesType.ASC:
        return -1;
      case MclLoopSortValuesType.DSC:
        return 1;
    }
  }
}
