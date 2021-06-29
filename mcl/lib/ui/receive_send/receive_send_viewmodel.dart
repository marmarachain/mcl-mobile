import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/services/ssh_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';

class ReceiveSendViewModel extends BaseViewModel {
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();
  final _sshService = locator<SshService>();
  final _navigationService = locator<NavigationService>();

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  final amountFocusNode = FocusNode();

  void contactsViewOpen() {
    _navigationService.navigateTo(Routes.contactView);
  }

  Future<void> navigatorHomeScreen() async {
    _navigationService.replaceWith(Routes.homeView);
  }

  Future<void> openContactBook(ctx) async {
    await showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return Container(height: 260.0, child: Text('I am text'));
      },
    );
  }

  Future<void> submitData(BuildContext ctx) async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${LocaleKeys.receivesend_missing.locale}')));
      return;
    }
    final enteredAddress = addressController.text;
    final enteredAmount = double.parse(amountController.text);

    if (enteredAddress.length != 34 || enteredAmount <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${LocaleKeys.receivesend_characterNumber.locale}')));
      return;
    }

    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.common_warning.locale}',
        description:
            '${LocaleKeys.receivesend_sendWarning.locale} ($enteredAmount MCL)',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      await EasyLoading.show(
        status: '${LocaleKeys.receivesend_sending.locale}',
        maskType: EasyLoadingMaskType.black,
      );
      String result =
          await _sshService.receiveSend(enteredAddress, enteredAmount);
      await EasyLoading.dismiss();
      if (result.length == 64) {
        showDialog(
            barrierDismissible: false,
            context: ctx,
            builder: (_) => AlertDialog(
                  title: Text('${LocaleKeys.wallet_successful.locale}'),
                  content: SelectableText(result),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: "$result"));
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                  '${LocaleKeys.common_copiedToClipboard.locale}')));
                        }),
                    ElevatedButton(
                        onPressed: () {
                          _navigationService.back();
                        },
                        child: Text('Ok'))
                  ],
                ));
      } else {
        _dialogService.showDialog(
            title: 'Gönderme Sonucu',
            description: '${LocaleKeys.receivesend_unlockAmount.locale}');
      }
    }
  }

  String getWalletAddress() {
    var address = _sshService.walletAddress;
    return address;
  }

  // String get getQrScanWalletAddress => _sshService.qrScanWalletAddress;

  void walletAddressSet(String address) {
    if (address == null) {
      addressController.text = '';
    } else {
      addressController.text = address;
    }

    notifyListeners();
  }

  Future<void> onClickCmd() async {
    // print(walletAddress);
    // if (walletAddress != null) {
    //   addressController.text = walletAddress;
    //   notifyListeners();
    // }
    setBusy(true);
    defterdonusumu();
    if (_sshService.walletAddress == '') {
      print("WALLET NULL İF İCİNDE");
      String result;
      try {
        result = await _sshService.chainViewModelStart();

        (jsonDecode(result) as List)
            .map((e) => e.toString())
            .toList()
            .asMap()
            .forEach((index, element) async {
          var test = await _sshService.chainViewAddressValidation(element);
          // print(test);
          // print(element);
          if (jsonDecode(test)['pubkey'] == _sshService.pubKey) {
            _sshService.walletAddress = element;
            // log.v('Wallet Address: $element');
          }

          notifyListeners();
        });
      } on PlatformException catch (e) {
        print('Error: ${e.code}\nError Message: ${e.message}');
      }
    }
    setBusy(false);
  }

  List<Person> _adresDefteriListesi = [];
  List<Person> get adresDefteriListesi => _adresDefteriListesi;
  List<Person> alAdresDefteri() {
    Box<dynamic> contactsBox = Hive.box<List<Person>>('kisiler');

    return (contactsBox as List<Person>);
  }

  void defterdonusumu() {
    Box<dynamic> contactsBox = Hive.box('kisiler');
    _adresDefteriListesi = [];
    contactsBox.values.forEach((kisiDetay) {
      _adresDefteriListesi.add(Person(
          isim: (kisiDetay as Person).isim,
          cuzdanAdresi: (kisiDetay as Person).cuzdanAdresi,
          pubKey: (kisiDetay as Person).pubKey));
    });

    print(_adresDefteriListesi.length);
  }

  bool _openQrCamera = false;
  bool get openQrCamera => _openQrCamera;
  set openQrCamera(bool value) {
    _openQrCamera = value;
    notifyListeners();
  }

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Widget buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      notifyListeners();
      // if (scanData.code != null) {
      //   addressController.text = scanData.code;
      //   _openQrCamera = false;
      //   notifyListeners();
      //   // controller.dispose();
      //   // _navigationService.back();
      // }
    });
  }
}
