import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/services/ssh_service.dart';
import 'package:mcl/widgets/common_bottom_sheet.dart';
import 'package:mcl/widgets/entered_text_common.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';

enum SingingCharacter { lafayette, jefferson }

class ChainViewModel extends BaseViewModel {
  final log = getLogger('ChainViewModel');

  final _sshService = locator<SshService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final DialogService _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  final workGroupController = TextEditingController();
  final workGroupControllerEqual = TextEditingController();

  final newwalletAddress = TextEditingController();
  final newPubkey = TextEditingController();
  late String newPrivateKey = '';
  late String agamapassphrase = '';

  String cmdLineResult = 'komut satırı';
  List? _array;

  late List<String> adresler;
  final List<Item> dataWallet = [];
  late String? activeChainWalletAddress;

  String? _character = '';
  String get character => _character!;
  set character(String deger) {
    _character = deger;
    notifyListeners();
  }

  bool _buttonStart = false;
  bool get buttonStart => _buttonStart;
  set buttonStart(bool deger) {
    _buttonStart = deger;
    notifyListeners();
  }

  bool _pubKeyIs = true;
  bool get pubKeyIs => _pubKeyIs;
  set pubKeyIs(bool deger) {
    _pubKeyIs = deger;
    notifyListeners();
  }

  int get secilenBlokZincirIndex => _sshService.mclSelectedBlocChainIndex!;

  // bool _switchStateStaking = false;
  // bool get switchStateStaking => _switchStateStaking;
  set switchStateStaking(bool value) {
    // _switchStateStaking = value;
    _sshService.setGenerateStakingTrue(value);
    notifyListeners();
  }

  bool _switchWordGroup = false;
  bool get switchWordGroup => _switchWordGroup;
  set switchWordGroup(bool value) {
    _switchWordGroup = value;
    notifyListeners();
  }

  Future<void> chainLogout() async {
    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.common_warning.locale}',
        description: '${LocaleKeys.chain_logout.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    if (onay!.confirmed) {
      await _sshService.logout();
      _navigationService.replaceWith(Routes.homeView);
    }
  }

  Future<void> navigatorHomeScreen() async {
    _navigationService.replaceWith(Routes.homeView);
  }

  Future<void> stateBlockChain() async {
    setBusy(true);
    await EasyLoading.show(
      status: '${LocaleKeys.home_loading.locale}...',
      maskType: EasyLoadingMaskType.black,
    );
    var infoBlock = await _sshService.getInfoBlockChain();
    await EasyLoading.dismiss();
    print(infoBlock);
    if (infoBlock == "loading block index") {
      _dialogService.showDialog(
          title: "${LocaleKeys.chain_blockIndexing.locale}",
          description: "${LocaleKeys.chain_description2.locale}");
    } else {
      cmdLineResult = infoBlock;
    }
    setBusy(false);
    notifyListeners();
  }

  Future<void> onClickCmd({bool isAddPriveKey = false}) async {
    // setBusy(true);

    String? result;
    try {
      // await _sshService.startBlockChain();

      if (_sshService.pubKey == '') {
        pubKeyIs = false;
        // getınfo sonrası '' alinirsa START VERİLECEK
        if (_sshService.chainWork == false || _sshService.pubKey == '') {
          await onClickMclStart(firstStart: true);

          await EasyLoading.show(
            status: '${LocaleKeys.home_loading.locale}...',
            maskType: EasyLoadingMaskType.black,
          );
          await Future.delayed(Duration(seconds: 3));
          var chainStartControl = "loading block index";
          while (chainStartControl == "loading block index") {
            var infoBlock = await _sshService.getInfoBlockChain();
            chainStartControl = infoBlock;
            print(infoBlock);
            await Future.delayed(Duration(seconds: 4));
            if (infoBlock == "loading block index") {
            } else {
              await EasyLoading.dismiss();
              stateBlockChain();
            }
          }

          _sshService.chainWork = true;
          await Future.delayed(Duration(seconds: 5));
        }

        notifyListeners();
      }
      //TODO dateWallet Hive ile cekilecek
      if (isAddPriveKey || dataWallet.length == 0) {
        await EasyLoading.show(
          status: '${LocaleKeys.home_loading.locale}...',
          maskType: EasyLoadingMaskType.black,
        );
        result = await _sshService.chainViewModelStart();
        await EasyLoading.dismiss();
        if (result == '') {
          _dialogService.showDialog(
              title: '${LocaleKeys.common_errorCreated.locale}');
        } else {
          adresler =
              (jsonDecode(result) as List).map((e) => e.toString()).toList();
          print(adresler);

          // await _sshService.getInfoBlockChain();

          dataWallet.clear();
          await Future.forEach(adresler, (String element) async {
            var test = await _sshService.chainViewAddressValidation(element);
            print(test);
            dataWallet.forEach((element) {
              print(element);
            });
            // print(element);
            if (jsonDecode(test)['pubkey'] == _sshService.pubKey) {
              _sshService.walletAddress = element;
              activeChainWalletAddress = element;
              log.v('Wallet Address: $element');
              dataWallet.add(Item(
                  id: dataWallet.length,
                  expandedValue: element,
                  headerValue: jsonDecode(test)['pubkey']));
              character = jsonDecode(test)['pubkey'];
              cmdLineResult = '';
            } else {
              dataWallet.add(Item(
                  id: dataWallet.length,
                  expandedValue: element,
                  headerValue: jsonDecode(test)['pubkey']));
              // buttonStart = true;
            }
            if (_sshService.pubKey == '') {
              cmdLineResult = '${LocaleKeys.chain_description3.locale}';
            }
            notifyListeners();
          });
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      // setBusy(false);
      setBusy(false);
      _dialogService.showDialog(
          title: '${LocaleKeys.chain_desciption4.locale}');
    }
    // setBusy(false);
  }

  Future<void> onClickChainStop() async {
    var onay = await _dialogService.showConfirmationDialog(
        title: '${LocaleKeys.common_warning.locale}',
        description: '${LocaleKeys.chain_description5.locale}',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    if (onay!.confirmed) {
      var onay2 = await _dialogService.showConfirmationDialog(
          title: '${LocaleKeys.common_warning.locale}',
          description: '${LocaleKeys.chain_description6.locale}',
          cancelTitle: '${LocaleKeys.common_no.locale}',
          confirmationTitle: '${LocaleKeys.common_yes.locale}');
      if (onay2!.confirmed) {
        setBusy(true);
        String result;
        try {
          result = await _sshService.chainStop();
          // print(result);
          buttonStart = true;
          character = '';
        } catch (e) {}
      }
    }

    setBusy(false);
  }

  // simdilik komut satırı stream olan kısımdan yapıyoruz: onClickMclStart()
  Future<void> onClickChainStart() async {
    setBusy(true);
    String result;
    try {
      result = await _sshService.chainStart(character);
      print(result);
    } catch (e) {}
    setBusy(false);
  }

  void _enteredServer(BuildContext context, String privateKey) {
    // passTx = txPassword;
    // runStartServer(serverIndex);
    Clipboard.setData(ClipboardData(text: privateKey));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('${LocaleKeys.chain_copiedToClipboard.locale}')));
    notifyListeners();
  }

  Future<void> _addPrivateKey(String txPrivateKey) async {
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    var result = await _sshService.chainPrivateKeyAdd(txPrivateKey);
    setBusy(false);
    await EasyLoading.dismiss();
    try {
      if (result.length > 2) {
        await EasyLoading.showSuccess(
            '${LocaleKeys.chain_description7.locale}');
        // await _dialogService.showDialog(
        //     title: '${LocaleKeys.chain_title1.locale}',
        //     description: '${LocaleKeys.chain_description7.locale}');
        onClickCmd(
            isAddPriveKey:
                true); // TODO private eklenmesi sonrası HATA olusuyor beyaz ekran geliyor
      } else {
        _dialogService.showDialog(
            title: '${LocaleKeys.chain_title1.locale}',
            description: '${LocaleKeys.common_errorCreated.locale}');
      }
    } catch (e) {}
  }

  Future<void> onClickPrivateKeyShow(ctx) async {
    print('onClickChainStart');
    setBusy(true);
    String result;
    try {
      result = await _sshService.chainPrivateKeyShow('');
      print(result);
      showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: CommonBottomSheet(
                _enteredServer, result, LocaleKeys.chain_seePrivate.locale),
            behavior: HitTestBehavior.opaque,
          );
        },
      );
    } catch (e) {}
    setBusy(false);
  }

  Future<void> onClickPrivateKeyAdd(ctx) async {
    print('onClickNewPrivateAdd');
    // setBusy(true);
    try {
      await showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: EnteredTextCommon(_addPrivateKey),
            behavior: HitTestBehavior.opaque,
          );
        },
      );
    } catch (e) {}
    // setBusy(false);
  }

  Future<void> onClickNewWalletAddressCreate(ctx) async {
    print('onClickNewWalletAddressCreate');

    // setBusy(true);
    if (workGroupController.text != workGroupControllerEqual.text) {
      EasyLoading.showError('Kelime Grupları eşleşmiyor');
    } else {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
      );
      String result;
      try {
        result = await _sshService
            .chainNewWalletAddressCreate(workGroupController.text);
        await EasyLoading.dismiss();
        print(result);
        if (result.length > 2) {
          newwalletAddress.text = jsonDecode(result)['address'];
          newPubkey.text = jsonDecode(result)['pubkey'];
          if (workGroupController.text == '') {
            newPrivateKey = await _sshService
                .chainPrivateKeyShow(jsonDecode(result)['address']);
          } else {
            newPrivateKey = jsonDecode(result)['wif'];
            // agamapassphrase = workGroupController.text;
            agamapassphrase = jsonDecode(result)['agamapassphrase'];
          }
          notifyListeners();
          await EasyLoading.showSuccess(
              '${LocaleKeys.chain_description8.locale}');
          // await showModalBottomSheet(
          //   context: ctx,
          //   builder: (_) {
          //     return GestureDetector(
          //       onTap: () {},
          //       child: CommonBottomSheet(_enteredServer, result,
          //           LocaleKeys.chain_description8.locale),
          //       behavior: HitTestBehavior.opaque,
          //     );
          //   },
          // );
          onClickCmd(isAddPriveKey: true);
        } else {
          _dialogService.showDialog(
              title: '${LocaleKeys.chain_title1.locale}',
              description: '${LocaleKeys.common_errorCreated.locale}');
        }
      } catch (e) {}
    }

    // setBusy(false);
  }

  void copiedToClipboard(
      BuildContext ctx, String copyText, String messageDown) {
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content:
            Text('$messageDown ${LocaleKeys.chain_copiedToClipboard.locale}')));
  }

  void copiedToClipboardNewWalletInfo(BuildContext ctx) {
    Clipboard.setData(ClipboardData(
        text:
            'agamapassphrase: $agamapassphrase \nCüzdan Adresi: ${newwalletAddress.text}\nPub Key: ${newPubkey.text}\nPrivate Key: $newPrivateKey'));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Yeni cüzdan bilgileri kopyalandı')));
  }

  Future<void> onClickMclStart({bool firstStart = false}) async {
    cmdLineResult = "";
    _array = null;

    try {
      String resultConnect;

      resultConnect = await _sshService.currentServer.startShell(
          ptyType: "xterm",
          callback: (dynamic res) {
            cmdLineResult = '';
            cmdLineResult += res;
            print(res);
            notifyListeners();
          });

      if (resultConnect == "shell_started") {
        print(await _sshService.currentServer
            .writeToShell("echo hello > world\n"));
        if (firstStart || character == '') {
          print(await _sshService.currentServer.writeToShell(
              "${_sshService.currentServer.pathMclCli}komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=149.202.158.145 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 &\n"));
        } else {
          pubKeyIs = true;
          _sshService.pubKey = character;
          print(await _sshService.currentServer.writeToShell(
              "${_sshService.currentServer.pathMclCli}komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=46.4.238.65 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 -gen -genproclimit=0 -pubkey=$character &\n"));
        }

        await EasyLoading.show(
          status: '${LocaleKeys.home_loading.locale}...',
          maskType: EasyLoadingMaskType.black,
        );
        await Future.delayed(Duration(seconds: 3));
        var chainStartControl = "loading block index";
        while (chainStartControl == "loading block index") {
          var infoBlock = await _sshService.getInfoBlockChain();
          chainStartControl = infoBlock;
          print(infoBlock);
          await Future.delayed(Duration(seconds: 4));
          if (infoBlock == "loading block index") {
          } else {
            await EasyLoading.dismiss();
          }
        }

        print(await _sshService.currentServer.writeToShell("cat world\n"));
      }
      buttonStart = false;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
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
