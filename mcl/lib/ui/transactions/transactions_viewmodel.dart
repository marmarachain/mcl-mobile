import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/transaction.dart';
import 'package:mcl/services/ssh_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';

class TransactionsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _sshService = locator<SshService>();

  double? valueSlider = 10.0;
  // double? get valueSlider => _valueSlider;
  void changeSlider(double values) {
    valueSlider = values;
  }

  double? valueSliderStart = 0.0;
  // double? get valueSlider => _valueSlider;
  void changeSliderStart(double values) {
    valueSliderStart = values;
  }

  RangeValues? _values;

  void changeRangeValues(RangeValues values) {
    _values = values;
  }

  Future<void> onClickListTransactions() async {
    print('onClickListTransactions');

    String? result;
    try {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      result = await _sshService.onClickListTransactions(
          count: valueSlider!.toInt(), start: valueSliderStart!.toInt());
      var transactionBox = Hive.box('transactions');
      // transactionBox.clear();
      if ((jsonDecode(result) as List).length != 0) {
        var sayma = 0;
        (jsonDecode(result) as List).reversed.forEach((element) {
          var transaction = Transaction(
              address: element['address'],
              category: element['category'],
              amount: element['amount'],
              txid: element['txid'],
              blocktime: element['blocktime'],
              timereceived: element['timereceived']);
          transactionBox.put(sayma, transaction);
          sayma = sayma + 1;
          notifyListeners();
        });

        notifyListeners();
        await EasyLoading.dismiss();
      } else {
        await EasyLoading.dismiss();
        _dialogService.showDialog(
            title: '${LocaleKeys.common_warning.locale}',
            description: '${LocaleKeys.common_errorCreated.locale}');
      }

      // client.disconnect(); #### TEST AMACLI PASIF #######
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  void panoyaKopyalandi(BuildContext ctx, String copyText, String messageDown) {
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content:
            Text('$messageDown ${LocaleKeys.chain_copiedToClipboard.locale}')));
  }

  void backPop() {
    _navigationService.back();
  }
}
