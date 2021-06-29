import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/services/ssh_service.dart';
import 'package:mcl/widgets/entered_server.dart';
import 'package:mcl/widgets/new_transaction.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:connectivity/connectivity.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _sshService = locator<SshService>();
  final DialogService _dialogService = locator<DialogService>();

  final _passwordServerController = TextEditingController();
  final PageController pageController = PageController();
  double currentPosition = 0;

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;
  set pageIndex(int value) {
    _pageIndex = value;
    currentPosition = value.toDouble();
    print("PAGEINDEX SELECTED: $value");
    notifyListeners();
  }

  Future<void> onClickCmd() async {}

  late String passTx;
  late int serverIndex;

  List<String> popMenu = [
    LocaleKeys.contact_name.locale,
    LocaleKeys.home_settings.locale
  ];
  // List<String> popMenuLanguage = [
  //   LocaleKeys.languages_turkish.locale,
  //   LocaleKeys.languages_english.locale,
  //   LocaleKeys.languages_arabic.locale
  // ];
  List<String> popMenuLanguage = ["AR", "EN", "TR"];

  int _selectedRadio = 0;
  int _selectedLanguage = 0;
  int selectedLanguage() {
    _selectedLanguage = _selectedLanguage == 2 ? 0 : _selectedLanguage + 1;
    notifyListeners();
    return _selectedLanguage;
  }

  int get ekliSunucuSayisi => Hive.box('sunucular').length;

  Future<void> languageChange() async {
    await Future.delayed(Duration(seconds: 2));
    popMenu = [LocaleKeys.contact_name.locale, LocaleKeys.home_settings.locale];
    notifyListeners();
  }

  int get getSecilenRadioGetir {
    return _selectedRadio;
  }

  void setSecilenRadioGotur(gelenRadio) {
    _selectedRadio = gelenRadio;
    notifyListeners();
  }

  void selectPopMenu(String choice) {
    print(choice);

    if (choice == popMenu[0]) {
      setSecilenRadioGotur(0);
      _navigationService.navigateTo(Routes.contactView);
    } else if (choice == popMenu[1]) {
      setSecilenRadioGotur(1);
    } else if (choice == popMenu[2]) {
      // ektra bi özellik eklenirse
    }
  }

  Future<void> selectPopMenuLang() async {
    await Future.delayed(Duration(seconds: 2));
    popMenuLanguage = [
      LocaleKeys.languages_turkish.locale,
      LocaleKeys.languages_english.locale,
      LocaleKeys.languages_arabic.locale
    ];
    notifyListeners();
  }

  Future<void> runStartServer(int index) async {
    final dashboardBox = Hive.box('dashboard');
    dashboardBox.put('selected_server_index', index);
    try {
      await EasyLoading.show(
        status: '${LocaleKeys.home_loading.locale}...',
        maskType: EasyLoadingMaskType.black,
      );
      String gelen = await _sshService.connectSshAccount(passTx);
      await EasyLoading.dismiss();
      if (gelen.length > 60) {
        _navigationService.replaceWith(Routes.mclDetailView,
            arguments: MclDetailViewArguments(passwordServer: gelen));
      } else if (gelen == 'run without pubkey') {
        _navigationService.replaceWith(Routes.mclDetailView,
            arguments:
                MclDetailViewArguments(passwordServer: 'run without pubkey'));
      } else if (gelen == 'MCL no') {
        await _dialogService.showDialog(
            title: 'Marmara',
            description: '${LocaleKeys.home_pubKeyStart.locale}',
            buttonTitle: '${LocaleKeys.common_ok.locale}');
        _navigationService.navigateTo(Routes.mclDetailView);
      } else if (gelen == 'mcl no') {
        await _dialogService.showDialog(
            title: 'Marmara',
            description: '${LocaleKeys.home_pubKeyStart.locale}',
            buttonTitle: '${LocaleKeys.common_ok.locale}');
        _navigationService.navigateTo(Routes.mclDetailView);
      } else {
        await _dialogService.showDialog(
            title: '${LocaleKeys.common_warning.locale}',
            description: '${LocaleKeys.home_warning.locale}',
            buttonTitle: '${LocaleKeys.common_ok.locale}');
      }
    } catch (e) {
      print(e);
    }
  }

  void _addNewTransaction(String txTitle, String txUsername, String txAddress,
      int txPort, int serverIdex) {
    final newTx = Chain(
      title: txTitle,
      username: txUsername,
      address: txAddress,
      port: txPort,
      // id: DateTime.now().toString(),
    );
    final contactsBox = Hive.box('sunucular');
    if (serverIdex == -1) {
      contactsBox.add(newTx);
    } else {
      contactsBox.putAt(serverIdex, newTx);
    }
    // final newContact = Contact(_name, int.parse(_age));
    // setState(() {
    //   _userTransactions.add(newTx);
    // });
  }

  void startAddNewTransaction(BuildContext ctx, Chain sunucu, int sunucuIndex) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction, sunucu, sunucuIndex),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _enteredServer(String txPassword) {
    passTx = txPassword;
    runStartServer(serverIndex);
    notifyListeners();
  }

  Future<void> passwordServerEnter(BuildContext ctx, int index) async {
    serverIndex = index;
    notifyListeners();
    // connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _dialogService.showDialog(
          title: '${LocaleKeys.home_netError.locale}',
          description: "${LocaleKeys.home_openNet.locale}");
    } else {
      // login check
      bool? hasConnectServer = _sshService.isServerConnect(index);
      if (hasConnectServer) {
        _navigationService.replaceWith(Routes.mclDetailView);
      } else {
        await showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              child: EnteredServer(_enteredServer),
              behavior: HitTestBehavior.opaque,
            );
          },
        );
      }
      // final currentServer = _sshService.currentServer;
      // if(currentServer.connect())
    }
  }

  Future<void> deleteServer(int indexServer) async {
    // kisilerBox.deleteAt(index)
    final serverBox = Hive.box('sunucular');
    var server = serverBox.getAt(indexServer);

    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.common_approve.locale}',
        description:
            '${LocaleKeys.home_deleteApprove.locale}(${(server as Chain).title} )',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      serverBox.deleteAt(indexServer);
    }
  }
}
