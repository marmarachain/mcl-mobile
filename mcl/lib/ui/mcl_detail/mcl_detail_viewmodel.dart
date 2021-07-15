import 'dart:convert';
import 'dart:io';
// import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/api/ssh_connect_api.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl/core/constants/enums/mcl_loop_enum.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/services/ssh_service.dart';
import 'package:mcl/utils/ssh.dart';
import 'package:mcl/widgets/credit_issuer_search.dart';
import 'package:mcl/widgets/kredi_ciranta_search.dart';
import 'package:mcl/widgets/new_transaction.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

import 'package:collection/collection.dart';

import 'package:mcl/utils/commands.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/js.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';

class MclDetailViewModel extends BaseViewModel {
  // stores ExpansionPanel state information

  // final _sshService = locator<SshConnectApi>();

  final log = getLogger('KrediViewModel');

  final _sshService = locator<SshService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final DialogService _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  TextEditingController cuzdanDeaktiflemeController = TextEditingController();
  TextEditingController cuzdanAktiflemeController = TextEditingController();
  final cuzdanAktiflemeFocusNode = FocusNode();
  final cuzdanDeaktiflemeFocusNode = FocusNode();

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(value) {
    _tabIndex = value;
    print("TABINDEX SELECTED: $value");
    notifyListeners();
    switch (value) {
      case 0:
        defterdonusumu();
        break;
      case 2:
        onClickCirantaDonguler();
        break;
      case 3:
        onClickAktifDonguler();
        break;
      default:
    }
  }

  int get secilenBlokZincirIndex => _sshService.mclSelectedBlocChainIndex!;

  String hamilKrediIstegiTopluAddLink = '';

  List<Person> _adresDefteriListesi = [];
  List<Person> get adresDefteriListesi => _adresDefteriListesi;
  String alAdresDefteri(kisiKaydi) {
    Box<dynamic> contactsBox = Hive.box<List<Person>>('kisiler');
    _adresDefteriListesi = (contactsBox as List<Person>);
    // print("defter sayısı---***********------${_adresDefteriListesi.length}");
    contactsBox.values.forEach((kisiDetay) {
      print((kisiDetay as Person).isim);
      // if ((kisiDetay as Person).pubKey == kisiKaydi) {
      //   return "";
      // }
      // if(true){}
    });
    return '';
  }

  void contactsViewOpen() {
    _navigationService.navigateTo(Routes.contactView);
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

  // Ortak metotlar start
  void panoyaKopyalandi(BuildContext ctx, String copyText, String messageDown) {
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            '$messageDown ${LocaleKeys.common_copiedToClipboard.locale}')));
  }
  // Ortak metotlar finish

  String? hostValue;
  int? portValue;
  String? usernameValue;
  String? passwordValue;

  SSHClient? client;

  RangeValues? _values;

  bool _isAscending = true;

  void changeRangeValues(RangeValues values) {
    _values = values;
  }

  void changeAscending(bool value) {
    _isAscending = value;
    notifyListeners();
  }

  Future<void> fetchMinMax() async {
    _navigationService.back();
    setBusy(true);
    // mainBurgerModel = await burgerService.fetchBurgersLimited(
    //     max: _values?.end, min: _values?.start);
    setBusy(false);
  }

  Future<void> fetchSort(MclLoopSortValues value) async {
    _navigationService.back();
    setBusy(true);
    switch (value) {
      case MclLoopSortValues.NAME:
        cirantaLoop.sort((a, b) {
          var adate = a.sendPerson; //before -> var adate = a.expiry;
          var bdate = b.sendPerson; //var bdate = b.expiry;
          if (_isAscending) {
            return adate!.compareTo(bdate!);
          }
          return -adate!.compareTo(bdate!);
        });
        cirantaLoop
            .asMap()
            .map((key, value) => MapEntry(key, value.id = key + 1));
        break;
      case MclLoopSortValues.AMOUNT:
        cirantaLoop.sort((a, b) {
          var adate = a.amount; //before -> var adate = a.expiry;
          var bdate = b.amount; //var bdate = b.expiry;
          if (_isAscending) {
            return adate!.compareTo(bdate!);
          }
          return -adate!.compareTo(bdate!);
        });
        cirantaLoop
            .asMap()
            .map((key, value) => MapEntry(key, value.id = key + 1));
        break;
      case MclLoopSortValues.MATURES:
        cirantaLoop.sort((a, b) {
          var adate = a.matures; //before -> var adate = a.expiry;
          var bdate = b.matures; //var bdate = b.expiry;
          if (_isAscending) {
            return adate!.compareTo(bdate!);
          }
          return -adate!.compareTo(bdate!);
        });
        cirantaLoop
            .asMap()
            .map((key, value) => MapEntry(key, value.id = key + 1));
        break;
      default:
    }
    print(value);
    notifyListeners();
    setBusy(false);
  }

  void denemeModel() {
    print(_sshService.pubKey);
  }

  // ISSUER METHODS START

  Future<void> _refreshIssuerForm(int txTimeDiffMinute) async {
    try {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      await onClickIssuerRefresh(txTimeDiffMinute);
      await EasyLoading.dismiss();
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  Future<void> issuerCreditConfirmationDialog(String message,
      String reveicePubKey, String txId, BuildContext ctx) async {
    setBusy(true);

    // notifyListeners();
    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.credit_name.locale}',
        description:
            '$message \n ${LocaleKeys.credit_issuer_creditApprove.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      String sendDogrulama =
          await _sshService.krediIstegiOnaylama(reveicePubKey, txId);
      if (sendDogrulama.length == 64) {
        showDialog(
            barrierDismissible: false,
            context: ctx,
            builder: (_) => AlertDialog(
                  title: Text('${LocaleKeys.wallet_successful.locale}'),
                  content: SelectableText(sendDogrulama),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: "$sendDogrulama"));
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
            title: 'Deaktifle Sonucu',
            description: 'Başarısız, daha sonra tekrar deneyin!');
      }
    }
    setBusy(false);
  }

  void issuerIsExpanded(index, isExpanded) {
    issuerLoop[index].isExpanded = isExpanded;
    notifyListeners();
  }

  Future<void> onClickIssuerRefresh(int afterDate) async {
    print(afterDate);
    print('onClickIssuerRefresh');

    String? result;
    try {
      result =
          await _sshService.onClickCreditIssuerRefresh(afterDate: afterDate);
      if (result == '') {
        issuerLoop = [];
        notifyListeners();
        _dialogService.showDialog(
            title: '${LocaleKeys.credit_issuer_list_first.locale}',
            description: '${LocaleKeys.credit_issuer_maturesNoRequest.locale}');
      } else if ((jsonDecode(result) as List).length > 0) {
        issuerLoop = [];
        (jsonDecode(result) as List).asMap().forEach((index, element) async {
          print(element);
          // holderLoopDetail[element] = {};
          var startTime = DateTime(2020, 01, 24, 10, 15);
          var fiftyDaysFromNow =
              startTime.add(new Duration(minutes: element['matures']));
          issuerLoop.add(IssuerLoop(
              isExpanded: false,
              id: index + 1,
              txid: element['txid'],
              amount: element['amount'],
              creationtxid: element['creationtxid'],
              funcid: element['funcid'],
              issuerpk: element['issuerpk'],
              matures: fiftyDaysFromNow.toString().substring(0, 16),
              receivepk: element['receivepk']));
        });
        notifyListeners();
      } else {
        issuerLoop = [];
        notifyListeners();
        _dialogService.showDialog(
            title: '${LocaleKeys.credit_issuer_list_first.locale}',
            description: '${LocaleKeys.credit_issuer_maturesNoRequest.locale}');
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }
  // ISSUER METHODS FINISH

  /* BEARER METHODS START */
  // KREDİ İŞLEMLERİ- HAMİL- İLK KREDİ İSTEĞİ
  late String bearerName = '';
  final bearerPubKeyController = TextEditingController();
  final bearerAmountOrBatonController = TextEditingController();
  final bearerAmountOrBatonFocusNode = FocusNode();
  DateTime? selectedDate;

  bool _switchState = false;
  bool get switchState => _switchState;
  set switchState(bool value) {
    _switchState = value;
    notifyListeners();
  }

  int? _selectedContact = 0;
  int get selectedContact => _selectedContact!;
  set selectedContact(int value) {
    _selectedContact = value;
    notifyListeners();
  }

  void presentDatePickerBearer(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2023),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      selectedDate = pickedDate;
      notifyListeners();
    });
    print('...');
  }

  Future<void> openContactBook(ctx) async {
    await showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return ValueListenableBuilder<Box<dynamic>>(
            valueListenable: Hive.box('kisiler').listenable(),
            builder: (context, kisilerBox, widget) {
              return Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Text('${LocaleKeys.common_addressSelect.locale}'),
                        IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                    Container(
                        // height: 350,
                        child: kisilerBox.isEmpty
                            ? Center(
                                child: Text(
                                  '${LocaleKeys.contact_yet.locale}',
                                  style: Theme.of(context).textTheme.title,
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                    itemCount: kisilerBox.length,
                                    itemBuilder: (ctx, index) {
                                      final kisi =
                                          kisilerBox.getAt(index) as Person;
                                      return ListTile(
                                        title: RichText(
                                            text: TextSpan(
                                                text: "${kisi.isim}  ",
                                                style: TextStyle(
                                                    color: Colors.black),
                                                children: [
                                              TextSpan(
                                                  text: 'MCL',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      backgroundColor:
                                                          Colors.grey))
                                            ])),
                                        subtitle: Text(kisi.pubKey),
                                        trailing: _selectedContact == index
                                            ? Icon(Icons.check)
                                            : SizedBox(),
                                        onTap: () {
                                          print(index);
                                          _selectedContact = index;
                                          bearerPubKeyController.text =
                                              kisi.pubKey;
                                          notifyListeners();
                                          Navigator.of(context).pop();
                                          openContactBook(ctx);
                                        },
                                      );
                                    }),
                              )),
                    ElevatedButton(
                        onPressed: () {
                          // bearerPubKeyController.text = ''
                          Navigator.of(context).pop();
                        },
                        child: Text('${LocaleKeys.common_approve.locale}'))
                  ],
                ),
              );
            });
      },
    );
  }

  Future<void> submitDataRequestCredi(BuildContext ctx) async {
    if (bearerAmountOrBatonController.text.isEmpty) {
      return;
    }
    final enteredPubKey = bearerPubKeyController.text;
    final enteredAmount;
    final enteredBaton;

    if (enteredPubKey.isEmpty || bearerAmountOrBatonController.text.isEmpty) {
      return;
    }
    if (!switchState && selectedDate == null) {
      return;
    }

    if (!switchState) {
      enteredAmount = double.parse(bearerAmountOrBatonController.text);
    } else {
      selectedDate = DateTime.now();
      enteredBaton = bearerAmountOrBatonController.text;
    }

    var accept = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.credit_holder_first_credit_request.locale}',
        description: !switchState
            ? '${LocaleKeys.credit_holder_approveHolder.locale}'
            : '${LocaleKeys.credit_holder_approveHolder.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    DateTime now = new DateTime.now();
    DateTime bearerDate =
        new DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime bearerDateTwo = new DateTime(selectedDate!.year,
        selectedDate!.month, selectedDate!.day, now.hour, now.minute);
    var diffbearer = bearerDateTwo.difference(bearerDate).inMinutes;
    print(bearerDate);
    print(bearerDateTwo);
    print("dakika farkı: $diffbearer");
    print(accept!.confirmed.toString());
    if (accept.confirmed) {
      String sendDogrulama = await _sshService.creditBearerRequest(
          bearerPubKeyController.text,
          bearerAmountOrBatonController.text,
          diffbearer);
      if (sendDogrulama.length == 64) {
        // _dialogService.showDialog(
        //     title: 'Kredi İsteği Sonucu', description: 'Başarılı');
        showDialog(
            barrierDismissible: false,
            context: ctx,
            builder: (_) => AlertDialog(
                  title: Text('${LocaleKeys.wallet_successful.locale}'),
                  content: SelectableText(sendDogrulama),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.add_link),
                        onPressed: () {
                          hamilKrediIstegiTopluAddLink =
                              "$hamilKrediIstegiTopluAddLink\n$bearerName batonTxId:\n$sendDogrulama";
                          Clipboard.setData(ClipboardData(
                              text: hamilKrediIstegiTopluAddLink));
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                  '${LocaleKeys.common_copiedToClipboard.locale}')));
                        }),
                    IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: "$bearerName batonTxId:\n$sendDogrulama"));
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
            title: '${LocaleKeys.credit_name.locale}',
            description: '${LocaleKeys.common_errorCreated.locale}');
      }
    }
    notifyListeners();

    // widget.addTx(
    //   enteredTitle,
    //   enteredAmount,
    //   _selectedDate,
    // );
  }
  /* BEARER METHODS FINISH */

  /* ENDORSER METHODS START */
  List<IssuerLoop> endorsementRequestList = [];

  bool _switchStateEndorser = false;
  bool get switchStateEndorser => _switchStateEndorser;
  set switchStateEndorser(bool value) {
    _switchStateEndorser = value;
    notifyListeners();
  }

  Future<void> onClickEndorsementRequestRefresh() async {
    String? result;
    try {
      result = await _sshService.onClickCreditIssuerRefresh(afterDate: 0);
      if ((jsonDecode(result) as List).length > 0) {
        endorsementRequestList = [];
        (jsonDecode(result) as List).asMap().forEach((index, element) async {
          print(element);
          // holderLoopDetail[element] = {};
          var startTime = DateTime(2020, 01, 24, 10, 15);
          var fiftyDaysFromNow =
              startTime.add(new Duration(minutes: element['matures']));
          if (element['funcid'] == 'R') {
            endorsementRequestList.add(IssuerLoop(
                isExpanded: false,
                id: index,
                txid: element['txid'],
                amount: element['amount'],
                creationtxid: element['creationtxid'],
                funcid: element['funcid'],
                issuerpk: element['issuerpk'],
                matures: fiftyDaysFromNow.toString().substring(0, 16),
                receivepk: element['receivepk']));
          }
        });
        notifyListeners();
      } else {
        _dialogService.showDialog(
            title: '${LocaleKeys.common_warning.locale}',
            description: '${LocaleKeys.common_errorCreated.locale}');
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }
  /* ENDORSER METHODS FINISH */

  Future<void> _addNewTransaction(
      int txTimeFrom, int txTimeTo, double minAmount, double maxAmount) async {
    print(txTimeFrom);
    print(txTimeTo);
    print(minAmount);
    print(maxAmount);
    setBusy(true);
    // notifyListeners();
    print('onClickCirantaSearch');

    String? result;
    try {
      result = await _sshService.onClickKrediCirantaRefresh(
          firstHeight: txTimeFrom,
          lastHeight: txTimeTo,
          minAmount: minAmount,
          maxAmount: maxAmount);
      if (jsonDecode(result)['holder'] != null) {
        cirantaLoop = [];
        jsonDecode(result)['issuances'].asMap().forEach((index, element) async {
          print(element);
          holderLoopDetail[element] = {};
          cirantaLoop.add(CirantaLoop(
              isExpanded: false, id: index, header: element, body: ''));
        });
        // serverInfoBox.put('marmaraholderloopsdetail', holderLoopDetail);
        krediCirantaTotalAmount = jsonDecode(result)['totalamount'].toString();
        notifyListeners();
      } else {
        _dialogService.showDialog(
            title: '${LocaleKeys.common_warning.locale}',
            description: '${LocaleKeys.common_errorCreated.locale}');
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  Future<void> acayipNedir() async {
    print("acayip start");
    final mclBox = Hive.box('sunucular');
    final mclBlockChain =
        mclBox.getAt(_sshService.mclSelectedBlocChainIndex!) as Chain;
    var detayliCirantaKredileri = mclBlockChain.marmaraholderloopsdetail!;

    await Future.forEach(detayliCirantaKredileri.keys.toList(),
        (String num) async {
      await onClickCirantaDonguDetay(num);
    });
    print("acayip finish");
  }

  Future<void> createExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    if (tabIndex == 2) {
      sheet.getRangeByName('A1').setText('No');
      sheet
          .getRangeByName('B1')
          .setText('${LocaleKeys.credit_endorser_filter_amount.locale}');
      sheet
          .getRangeByName('C1')
          .setText('${LocaleKeys.credit_endorser_filter_matures.locale}');
      sheet
          .getRangeByName('D1')
          .setText('${LocaleKeys.credit_endorser_filter_name.locale}');
      sheet.getRangeByName('E1').setText('Pub Key');
      cirantaLoop.asMap().forEach((index, element) async {
        print(element);
        sheet
            .getRangeByName('A${(index + 2).toString()}')
            .setText('${(index + 1).toString()}');
        sheet
            .getRangeByName('B${(index + 2).toString()}')
            .setText(element.amount.toString());
        sheet
            .getRangeByName('C${(index + 2).toString()}')
            .setText('${DateFormat('dd.MM.yyyy').format(element.matures!)}');
        sheet
            .getRangeByName('E${(index + 2).toString()}')
            .setText(element.sendPubKey);
        if (element.sendPubKey != element.sendPerson) {
          sheet
              .getRangeByName('D${(index + 2).toString()}')
              .setText(element.sendPerson);
        }
      });
    } else if (tabIndex == 3) {
      sheet.getRangeByName('A1').setText('No');
      sheet
          .getRangeByName('B1')
          .setText('${LocaleKeys.credit_endorser_filter_amount.locale}');
      sheet
          .getRangeByName('C1')
          .setText('${LocaleKeys.credit_endorser_transactinAddress.locale}');
      dataLoop.asMap().forEach((index, element) async {
        print(element);
        sheet
            .getRangeByName('A${(index + 2).toString()}')
            .setText('${(index + 1).toString()}');
        sheet
            .getRangeByName('B${(index + 2).toString()}')
            .setText(element.myAmountLockedInLoopValue.toString());
        sheet
            .getRangeByName('C${(index + 2).toString()}')
            .setText(element.loopAddressValue);
      });
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  Future<void> startCirantaSearch(BuildContext ctx) async {
    setBusy(true);
    switch (tabIndex) {
      case 0:
        await showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              child: IssuerSearchRefresh(_refreshIssuerForm),
              behavior: HitTestBehavior.opaque,
            );
          },
        );
        break;
      case 2:
        await showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              child: CirantaSearchRefresh(_addNewTransaction),
              behavior: HitTestBehavior.opaque,
            );
          },
        );
        break;
      default:
        // TODO ciranta hamilleiri excelle dökme süreci yazılacak
        print('Tüm ciranta hamil döngüleri excel dosyasından indiriliyor');
        createExcel();
    }
    setBusy(false);
  }

  String myWalletAmount(String type) {
    final dashboardBox = Hive.box('sunucu-info');
    var account = dashboardBox.get('marmarainfo-1');
    // print(account);
    var deger = jsonDecode(account);
    print(deger[type]);
    return deger[type].toString();
  }

  Future<void> myWalletNormalAmountButton(BuildContext ctx) async {
    if (_sshService.pubKey == '') {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${LocaleKeys.chain_startPubkey.locale}')));
    } else {
      // setBusy(true);
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      await _sshService.marmaraInfoBlocChain();
      await EasyLoading.dismiss();
      // setBusy(false);
      notifyListeners();
    }
  }

  Future<void> cuzdanDegerAktifleme() async {
    if (cuzdanAktiflemeController.text.isEmpty) {
      return;
    }
    // setBusy(true);

    // notifyListeners();
    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.wallet_amountActivate.locale}',
        description: '${LocaleKeys.wallet_activateApprove.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      String sendDogrulama = await _sshService
          .cuzdanAktifleme(int.parse(cuzdanAktiflemeController.text));
      await EasyLoading.dismiss();
      if (sendDogrulama.length == 64) {
        _dialogService.showDialog(
            title: '${LocaleKeys.wallet_amountActivate.locale}',
            description: '${LocaleKeys.wallet_successful.locale}');
      } else {
        _dialogService.showDialog(
            title: '${LocaleKeys.wallet_amountActivate.locale}',
            description: '${LocaleKeys.wallet_failed.locale}');
      }
    }
    // setBusy(false);
  }

  Future<void> cuzdanDegerDeaktifleme() async {
    if (cuzdanDeaktiflemeController.text.isEmpty) {
      return;
    }
    // if (int.parse(cuzdanDeaktiflemeController.text) > 0) {
    //   return;
    // }
    // setBusy(true);

    // setBusy(false);

    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.wallet_amountDeactivate.locale}',
        description: '${LocaleKeys.wallet_deactivateApprove.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      var sendDogrulama = await _sshService
          .cuzdanDeaktifleme(int.parse(cuzdanDeaktiflemeController.text));
      await EasyLoading.dismiss();
      // bool sendDogrulama = await _sshService.cuzdanDeaktiflemeOnayi(sendtx);
      if (sendDogrulama.length == 64) {
        _dialogService.showDialog(
            title: '${LocaleKeys.wallet_amountDeactivate.locale}',
            description: '${LocaleKeys.wallet_successful.locale}');
      } else {
        _dialogService.showDialog(
            title: '${LocaleKeys.wallet_amountDeactivate.locale}',
            description: '${LocaleKeys.wallet_failed.locale}');
      }
    }
  }

  List<Item> generateItems(int numberOfItems) {
    return List<Item>.generate(numberOfItems, (int index) {
      return Item(
        id: index,
        headerValue: 'Panel $index',
        expandedValue: 'This is item number $index',
      );
    });
  }

  late List<Item> data = generateItems(4);

  List<Item> generateWallets(int numberOfItems) {
    return List<Item>.generate(numberOfItems, (int index) {
      return Item(
        id: index,
        headerValue: 'Cüzdan $index',
        expandedValue: adresler[index],
      );
    });
  }

  // late List<Item> dataWallet = generateWallets(adresler.length);
  final List<Item> dataWallet = [];
  List<ItemLoop> dataLoop = [];
  List<CirantaLoop> cirantaLoop = [];
  List<IssuerLoop> issuerLoop = [];
  // List<ItemLoopDetail> cirantaLoopDetail = [];
  Map<String, dynamic> holderLoopDetail = {};

  late List<String> adresler;
  String? krediCirantaTotalAmount;

  void cirantoIsExpande(index, isExpanded) {
    cirantaLoop[index].isExpanded = isExpanded;
    notifyListeners();
  }

  Future<String> getCmdMcl(ctx, cmd, pubKey) async {
    print('baglantı kuruluyor...');
    var test = await client!
        .execute("./komodo/src/komodo-cli -ac_name=MCL $cmd $pubKey");
    print(test);
    if (test != null) {
      // await _bottomSheetService.showBottomSheet(title: test);
      showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: Wrap(
              children: [
                Text(test),
                IconButton(icon: Icon(Icons.copy), onPressed: () {})
              ],
            ),
            behavior: HitTestBehavior.opaque,
          );
        },
      );
    }
    return test;
  }

  Future<void> onClickCmd(String passServer, String command) async {
    setBusy(true);

    final dashboardBox = Hive.box('dashboard');
    int indexServer = dashboardBox.get('selected_server_index');

    final sunucularBox = Hive.box('sunucular');
    final sunucu = sunucularBox.getAt(indexServer) as Chain;

    hostValue = sunucu.address;
    portValue = sunucu.port;
    usernameValue = sunucu.title;
    passwordValue = passServer;
    notifyListeners();

    client = new SSHClient(
      host: hostValue!,
      port: portValue!,
      username: usernameValue!,
      passwordOrKey: passwordValue,
    );

    String result;
    try {
      result = await client!.connect();
      if (result == "session_connected") {
        result = await client!.execute(command);
        final dashboardBox = Hive.box('dashboard');
        dashboardBox.put('sunucu1', result);
        adresler =
            (jsonDecode(result) as List).map((e) => e.toString()).toList();
        print('ADRESLER');
        print(adresler);

        var test = await client!
            .execute("./komodo/src/komodo-cli -ac_name=MCL getinfo");
        print(test);
        _sshService.pubKey = jsonDecode(test)['pubkey'];

        adresler.asMap().forEach((index, element) async {
          result = await client!.connect();
          var test = await client!.execute(
              "./komodo/src/komodo-cli -ac_name=MCL validateaddress $element");
          print(test);
          print(element);
          if (jsonDecode(test)['pubkey'] == _sshService.pubKey) {
            _sshService.walletAddress = element;
            log.v('Wallet Address: $element');
          }
          dataWallet.add(Item(
              id: index + 1,
              expandedValue: element,
              headerValue: jsonDecode(test)['pubkey']));
          notifyListeners();
        });

        client!.disconnect();
      }

      // client.disconnect(); #### TEST AMACLI PASIF #######
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  void serverServisiBaglantisi() {
    _sshService.sshdenemebaglanti();
  }

  // @override
  // Future futureToRun() async {
  //   onClickCmd();
  // }

  Future<void> onClickAktifDonguler() async {
    setBusy(true);

    Map result;
    try {
      // 1. serverIndek alma yöntemi
      // final dashboardBox = Hive.box('dashboard');
      // int indexServer = dashboardBox.get('selected_server_index');

      // 2. serverIndex alma yöntemi
      // _sshService.mclSelectedBlocChainIndex;
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );

      final contactsBox = Hive.box('sunucular');
      final mclBlockChain = contactsBox.getAt(secilenBlokZincirIndex) as Chain;
      // result = await _sshService.marmaraInfo();
      if (mclBlockChain.marmarainfo! == null) {
        await _sshService.marmaraInfoBlocChain();
      }
      result = mclBlockChain.marmarainfo!; //

      dataLoop = [];
      result['Loops'].asMap().forEach((index, element) async {
        print(element['LoopAddress']);

        dataLoop.add(ItemLoop(
            id: index + 1,
            loopAddressValue: element['LoopAddress'],
            myAmountLockedInLoopValue:
                element['myAmountLockedInLoop'].toString(),
            txBatonValue:
                '')); // eksik burada başka bir client sorgusu ile txBaton alınabilir mi?
        // jsonDecode(result)['issuances'][index]
      });
      notifyListeners();
      await EasyLoading.dismiss();
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  // TabController? tabController = TabController(length: 3, vsync: null);

  Future<void> navigatorHomeScreen() async {
    _navigationService.replaceWith(Routes.homeView);
  }

  Future<void> creditCustomRefresh(BuildContext ctx) async {
    switch (tabIndex) {
      case 0:
        await showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              child: IssuerSearchRefresh(_refreshIssuerForm),
              behavior: HitTestBehavior.opaque,
            );
          },
        );
        break;
      case 2:
        if (!switchStateEndorser) {
          // onClickCirantaHamilRefresh();
          await showModalBottomSheet(
            context: ctx,
            builder: (_) {
              return GestureDetector(
                onTap: () {},
                child: CirantaSearchRefresh(onClickCirantaHamilRefresh),
                behavior: HitTestBehavior.opaque,
              );
            },
          );
        } else {
          onClickEndorsementRequestRefresh();
        }
        break;
      default:
    }
  }

  Future<void> onClickCirantaHamilRefresh(
      int txTimeFrom, int txTimeTo, double minAmount, double maxAmount) async {
    setBusy(true);
    // notifyListeners();
    print('onClickCirantaHamilRefresh');
    await Future.delayed(Duration(seconds: 4));

    String? result;
    try {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      result = await _sshService.onClickKrediCirantaRefresh(
          firstHeight: txTimeFrom,
          lastHeight: txTimeTo,
          minAmount: minAmount,
          maxAmount: maxAmount);
      if (jsonDecode(result)['holder'] != null) {
        final contactsBox = Hive.box('sunucular');
        final mclBlockChain =
            contactsBox.getAt(_sshService.mclSelectedBlocChainIndex!) as Chain;
        mclBlockChain.marmaraholderloops = jsonDecode(result);
        contactsBox.putAt(
            _sshService.mclSelectedBlocChainIndex!, mclBlockChain);

        cirantaLoop = [];
        jsonDecode(result)['issuances'].asMap().forEach((index, element) async {
          print(element);
          holderLoopDetail[element] = {};
        });
        krediCirantaTotalAmount = jsonDecode(result)['totalamount'].toString();

        mclBlockChain.marmaraholderloopsdetail = holderLoopDetail;
        contactsBox.putAt(
            _sshService.mclSelectedBlocChainIndex!, mclBlockChain);
        await acayipNedir();
        await onClickCirantaDonguler();
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

  Future<void> onClickCirantaDonguler() async {
    setBusy(true);
    try {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      final serverInfoBox = Hive.box('sunucular');
      var serverDetail = (serverInfoBox
          .getAt(_sshService.mclSelectedBlocChainIndex!) as Chain);
      if (serverDetail.marmaraholderloops != null) {
        Box<dynamic> contactsBox = Hive.box('kisiler');

        cirantaLoop = [];
        var detayliCirantaKredileri = serverDetail.marmaraholderloopsdetail!;
        detayliCirantaKredileri.keys
            .toList()
            .asMap()
            .forEach((index, element) async {
          // print(element);
          // holderLoopDetail[element] = {};
          var kisiVar = '';
          var kisiPubkey = '';
          contactsBox.values.forEach((kisiDetay) {
            print((kisiDetay as Person).isim);
            if ((kisiDetay as Person).pubKey ==
                ((detayliCirantaKredileri[element]['creditloop'] as List)
                            .length ==
                        1
                    ? (detayliCirantaKredileri[element]['creditloop']
                        as List)[0]['issuerpk']
                    : (detayliCirantaKredileri[element]['creditloop'] as List)
                        .last['receiverpk'])) {
              kisiVar = (kisiDetay as Person).isim;
              // kisiPubkey = ((detayliCirantaKredileri[element]['creditloop']
              //                 as List)
              //             .length ==
              //         1
              //     ? (detayliCirantaKredileri[element]['creditloop'] as List)[0]
              //         ['issuerpk']
              //     : (detayliCirantaKredileri[element]['creditloop'] as List)
              //         .last['receiverpk']);
            }
            // else {
            //   kisiPubkey = ((detayliCirantaKredileri[element]['creditloop']
            //                   as List)
            //               .length ==
            //           1
            //       ? (detayliCirantaKredileri[element]['creditloop'] as List)[0]
            //           ['issuerpk']
            //       : (detayliCirantaKredileri[element]['creditloop'] as List)
            //           .last['receiverpk']);
            //   // kisiVar = kisiPubkey;
            // }

            // TODO ELSE KISMI YAZILACAK PUBKEY '' kisi bilgisi yoksa gorunmemesi icin
          });
          cirantaLoop.add(CirantaLoop(
              isExpanded: false,
              id: index + 1,
              header: detayliCirantaKredileri[element][
                  'batontxid'], // header:element kısmi batonid 2 den fazla islemde ilk batonid cıktıgı icin degistirildi
              amount: detayliCirantaKredileri[element]['amount'],
              matures: (detayliCirantaKredileri[element]['matures'] as int)
                  .toMclStartDateTime,
              sendPubKey: ((detayliCirantaKredileri[element]['creditloop']
                              as List)
                          .length ==
                      1
                  ? (detayliCirantaKredileri[element]['creditloop'] as List)[0]
                      ['issuerpk']
                  : (detayliCirantaKredileri[element]['creditloop'] as List)
                      .last['receiverpk']),
              sendPerson: kisiVar,
              body:
                  "${detayliCirantaKredileri[element]['amount'].toString()}-${detayliCirantaKredileri[element]['matures'].toString().toDateTime}"));
        });

        notifyListeners();
        await EasyLoading.dismiss();
      } else {
        onClickCirantaHamilRefresh(0, 0, 0.0, 0.0);
      }

      // client.disconnect(); #### TEST AMACLI PASIF #######
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    setBusy(false);
  }

  Future<String?> onClickCirantaDonguDetay(String batonId) async {
    // setBusy(true);

    var result;
    try {
      // final serverInfoBox = Hive.box('sunucu-info');
      // var holderloopdetail = serverInfoBox.get('marmaraholderloopsdetail');
      final serverInfoBox = Hive.box('sunucular');
      var serverDetail = (serverInfoBox
          .getAt(_sshService.mclSelectedBlocChainIndex!) as Chain);
      if (true) {
        result = await _sshService.onClickCirantaDonguDetay(batonId);

        var testsonuc = jsonDecode(result!);
        serverDetail.marmaraholderloopsdetail![batonId] = testsonuc;
        print("SONUC DEGER ${serverDetail.marmaraholderloopsdetail![batonId]}");
        // TODO PUT OLANI DENENECEK FAZLA VERİ AKTARIMI OLMAMASI ICIN
        serverInfoBox.putAt(
            _sshService.mclSelectedBlocChainIndex!, serverDetail);
      }
      return 'void olacak donmesin';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    // setBusy(false);
  }

  bool _openQrCamera = false;
  bool get openQrCamera => _openQrCamera;
  set openQrCamera(bool value) {
    _openQrCamera = value;
    notifyListeners();
  }

  void walletAddressSet(String address) {
    bearerPubKeyController.text = address;
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

class Item {
  Item({
    required this.id,
    required this.expandedValue,
    required this.headerValue,
  });

  int id;
  String expandedValue;
  String headerValue;
}

class ItemLoop {
  ItemLoop(
      {required this.id,
      required this.loopAddressValue,
      required this.myAmountLockedInLoopValue,
      required this.txBatonValue});

  int id;
  String loopAddressValue;
  String myAmountLockedInLoopValue;
  String txBatonValue;
}

class ItemLoopDetail {
  ItemLoopDetail(
      {required this.batonid,
      required this.amount,
      required this.myAmountLockedInLoopValue,
      required this.txBatonValue});

  String batonid;
  String amount;
  String myAmountLockedInLoopValue;
  String txBatonValue;
}

class CirantaLoop {
  CirantaLoop({
    required this.isExpanded,
    required this.id,
    required this.header,
    required this.body,
    this.amount,
    this.matures,
    this.sendPubKey,
    this.sendPerson,
  });

  bool isExpanded;
  int id;
  String? header;
  String? body;
  double? amount;
  DateTime? matures;
  String? sendPubKey;
  String? sendPerson;
}

class IssuerLoop {
  IssuerLoop({
    required this.isExpanded,
    required this.id,
    required this.txid,
    required this.creationtxid,
    required this.funcid,
    required this.amount,
    required this.matures,
    required this.receivepk,
    required this.issuerpk,
  });

  bool isExpanded;
  int id;
  String? txid;
  String? creationtxid;
  String funcid;
  double? amount;
  String? matures;
  String? receivepk;
  String? issuerpk;
}
