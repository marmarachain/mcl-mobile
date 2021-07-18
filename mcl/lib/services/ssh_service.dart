import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/utils/commands.dart';
import 'package:mcl/utils/ssh.dart';

class SshService {
  final log = getLogger('SshService');

  // final _sshConnetApi = locator<SshConnectApi>();

  SSHClient? _currentServer;
  SSHClient? _currentServer0;
  SSHClient? _currentServer1;
  SSHClient? _currentServer2;

  int? mclSelectedBlocChainIndex;

  String? _qrScanWalletAddress = '';
  String get qrScanWalletAddress => _qrScanWalletAddress!;
  set qrScanWalletAddress(String value) {
    _qrScanWalletAddress = value;
  }

  SSHClient get currentServer => _currentServer!;

  String? _pubKey = '';
  String get pubKey => _pubKey!;
  set pubKey(String deger) {
    _pubKey = deger;
  }

  String? _walletAddress = '';
  String get walletAddress => _walletAddress!;
  set walletAddress(String deger) {
    _walletAddress = deger;
  }

  bool? _chainWork = true;
  bool get chainWork => _chainWork!;
  set chainWork(bool deger) {
    _chainWork = deger;
  }

  String? pathCli;

  Future<void> logout() async {
    switch (mclSelectedBlocChainIndex) {
      case 0:
        _currentServer0!.disconnect();
        _currentServer0 = null;
        break;
      case 1:
        _currentServer1!.disconnect();
        _currentServer1 = null;
        break;
      case 2:
        _currentServer2!.disconnect();
        _currentServer2 = null;
        break;
      default:
    }
    mclSelectedBlocChainIndex = -1;
    await _currentServer!.disconnect();
    _currentServer = null;
  }

  Future<String> connectSshAccount(String passServer) async {
    log.v('Connect ssh');

    final dashboardBox = Hive.box('dashboard');
    int indexServer = dashboardBox.get('selected_server_index');

    final sunucularBox = Hive.box('sunucular');
    final sunucu = sunucularBox.getAt(indexServer) as Chain;
    print(sunucu.port);

    var hostValue = sunucu.address;
    var portValue = sunucu.port;
    var usernameValue = sunucu.username;
    var passwordValue = passServer;

    try {
      SSHClient sshAccount = SSHClient(
          host: hostValue,
          port: portValue,
          username: usernameValue,
          passwordOrKey: passwordValue);
      var result = await sshAccount.connect();

      if (result == "session_connected") {
        log.v('Ssh connected!');
        switch (indexServer) {
          case 0:
            _currentServer0 = sshAccount;
            _currentServer = sshAccount;
            mclSelectedBlocChainIndex = 0;
            break;
          case 1:
            _currentServer1 = sshAccount;
            _currentServer = sshAccount;
            mclSelectedBlocChainIndex = 1;
            break;
          case 2:
            _currentServer2 = sshAccount;
            _currentServer = sshAccount;
            mclSelectedBlocChainIndex = 2;
            break;
          default:
        }
        // _currentServer = sshAccount;
        var mclFile = await _currentServer!
            .execute('find ~/.komodo -iname "MCL" -type d');
        print(mclFile);
        if (mclFile == '') {
          chainWork = false;
          return 'MCL no';
        }
        var cliFile =
            await _currentServer!.execute('find / -iname "komodo-cli"');
        print(cliFile);
        if (cliFile != '') {
          var newPath = cliFile.replaceAll("\n", "").replaceAll("\r", "");
          pathCli = newPath
                  .split('/')
                  .sublist(0, newPath.split('/').length - 1)
                  .join('/') +
              '/';
          _currentServer!.pathMclCli = newPath
                  .split('/')
                  .sublist(0, newPath.split('/').length - 1)
                  .join('/') +
              '/';
        }
        var test =
            await _currentServer!.execute("$pathCli${commands['getinfo']}");
        if (test != '') {
          if (jsonDecode(test)['pubkey'] != null) {
            pubKey = jsonDecode(test)['pubkey'];
            // pubKey = '';
            log.v('PubKey: $pubKey');
            return pubKey;
          }
          return 'run without pubkey';
        } else {
          chainWork = false;
          return 'mcl no';
        }
      }
      return 'no connect';
    } catch (e) {
      log.e(e.toString());
      return '';
    }
  }

  Future<String> onClickKrediCirantaRefresh(
      {int firstHeight = 0,
      int lastHeight = 0,
      double minAmount = 0,
      double maxAmount = 0}) async {
    try {
      var result = await _currentServer!.execute(
          "$pathCli${commands['marmaraholderloops']} $firstHeight $lastHeight $minAmount $maxAmount $_pubKey");

      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<void> marmaraInfoBlocChain() async {
    String result;
    try {
      result = await _currentServer!.connect();
      if (result == "session_connected") {
        result = await _currentServer!
            .execute("$pathCli${commands['marmarainfo']} $pubKey");

        final contactsBox = Hive.box('sunucular');
        final mclBlockChain =
            contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
        mclBlockChain.marmarainfo = jsonDecode(result);
        contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<String> krediIstegiOnaylama(String receivePubKey, String txId) async {
    try {
      var sendtxid = await _currentServer!.execute(
          '''$pathCli${commands['marmaraissue']} $receivePubKey '{"avalcount":"0", "autosettlement":"true", "autoinsurance":"true", "disputeexpires":"0", "EscrowOn":"false", "BlockageAmount":"0" }' $txId''');

      var rawSendTxId = sendtxid.replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.execute(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        print(sendOnayi);
        if (sendOnayi.length > 2) {
          return sendOnayi.replaceAll("\n", "").replaceAll("\r", "");
        }
      }

      return '';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> cuzdanAktifleme(int amount) async {
    try {
      var sendtxid = await _currentServer!
          .execute("$pathCli${commands['marmaralock']} $amount");

      var rawSendTxId = sendtxid.replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.execute(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        print(sendOnayi);
        if (sendOnayi.length > 2) {
          return sendOnayi.replaceAll("\n", "").replaceAll("\r", "");
        }
      }
      return '';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> cuzdanDeaktifleme(int amount) async {
    try {
      var sendtxid = await _currentServer!
          .execute("$pathCli${commands['marmaraunlock']} $amount");
      // print(sendtxid);
      // print(sendtxid.contains("\n"));
      // print(sendtxid.replaceAll("\n", "").contains("\n"));
      // print(sendtxid.replaceAll("\n", "").replaceAll("\r", "").length);
      // print(sendtxid
      //     .substring(sendtxid.length - 4, sendtxid.length)
      //     .codeUnits
      //     .toString());
      var rawSendTxId = sendtxid.replaceAll("\n", "").replaceAll("\r", "");
      // Map jsonHex = jsonDecode(rawSendTxId);
      if (true) {
        var sendOnayi = await _currentServer!.execute(
            "$pathCli${commands['sendrawtransaction']} '$rawSendTxId'");
        print(sendOnayi);
        if (sendOnayi.length > 2) {
          return sendOnayi.replaceAll("\n", "").replaceAll("\r", "");
        }
      }
      return '';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<bool> cuzdanDeaktiflemeOnayi(String gelensendTxId) async {
    try {
      print("$pathCli${commands['sendrawtransaction']} '$gelensendTxId'");
      print(commands['sendrawtransaction']);
      print(gelensendTxId);
      print(gelensendTxId.length);
      var sendOnayi = await _currentServer!.execute(
          "./komodo/src/komodo-cli -ac_name=MCL sendrawtransaction '$gelensendTxId'");
      print(sendOnayi);
      if (sendOnayi.length > 2) {
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return false;
    }
  }

  Future<String?> onClickCirantaDonguDetay(String batonId) async {
    try {
      var result = await _currentServer!
          .execute("$pathCli${commands['marmaracreditloop']}$batonId");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<String> receiveSend(String receiverAddress, double amount) async {
    try {
      var sendtxid = await _currentServer!.execute(
          '$pathCli${commands['sendtoaddress']} "$receiverAddress" $amount');

      var rawSendTxId = sendtxid.replaceAll("\n", "").replaceAll("\r", "");

      if (rawSendTxId.length == 64) {
        return rawSendTxId;
      }

      return '';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  void sshdenemebaglanti() async {
    var result = await _currentServer!.connect();
    print("SERVER ICINDEN BAGLANTI KONTROL");
    print(result);
    var komut = await _currentServer!
        .execute("$pathCli${commands['getaddressesbyaccount']}");
    print(komut);
  }

  bool isServerConnect(int serverIndex) {
    print(chainWork);
    try {
      switch (serverIndex) {
        case 0:
          var result = _currentServer0!.connect();
          _currentServer = _currentServer0;
          mclSelectedBlocChainIndex = 0;
          pathCli = _currentServer!.pathMclCli;
          print(result);
          return true;
        // break;
        case 1:
          var result = _currentServer1!.connect();
          _currentServer = _currentServer1;
          mclSelectedBlocChainIndex = 1;
          pathCli = _currentServer!.pathMclCli;
          print(result);
          return true;
        case 2:
          var result = _currentServer2!.connect();
          _currentServer = _currentServer2;
          mclSelectedBlocChainIndex = 2;
          pathCli = _currentServer!.pathMclCli;
          print(result);
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> chainViewModelStart() async {
    String result;

    try {
      result = await _currentServer!
          .execute("$pathCli${commands['getaddressesbyaccount']}");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainViewAddressValidation(String walletAddress) async {
    String result;
    try {
      result = await _currentServer!
          .execute("$pathCli${commands['validateaddress']} $walletAddress");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainStop() async {
    String result;
    try {
      result = await _currentServer!.execute("$pathCli${commands['stop']}");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainStart(String gelenPuKey) async {
    String result;
    try {
      result = await _currentServer!
          .execute("$pathCli${commands['start']}$gelenPuKey &");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainPrivateKeyShow(String getWalletAddress) async {
    print(pubKey);
    var searchWalletAddress;
    if (getWalletAddress == '') {
      searchWalletAddress = walletAddress;
    } else {
      searchWalletAddress = getWalletAddress;
    }
    String result;
    try {
      result = await _currentServer!
          .execute("$pathCli${commands['dumpprivkey']} $searchWalletAddress &");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainPrivateKeyAdd(String privateKey) async {
    try {
      var findWalletAddress = await _currentServer!
          .execute("$pathCli${commands['importprivkey']} $privateKey");
      var checkAddress = await _currentServer!.execute(
          "$pathCli${commands['validateaddress']} $findWalletAddress &");
      print(jsonDecode(checkAddress)['isvalid']);
      print(jsonDecode(checkAddress));
      if (jsonDecode(checkAddress)['isvalid']) {
        return findWalletAddress;
      } else {
        return '';
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainNewWalletAddressCreate(String workGroup) async {
    String result;
    try {
      if (workGroup == '') {
        var newwalletaddress = await _currentServer!
            .execute("$pathCli${commands['getnewaddress']}");
        result = await _currentServer!
            .execute("$pathCli${commands['dumpprivkey']} $newwalletaddress");
        var checkAddress = await _currentServer!.execute(
            "$pathCli${commands['validateaddress']} $newwalletaddress &");
        print(jsonDecode(checkAddress)['isvalid']);
        print(jsonDecode(checkAddress));
        if (jsonDecode(checkAddress)['isvalid']) {
          return checkAddress;
        } else {
          return '';
        }
      } else {
        result = await _currentServer!
            .execute('$pathCli${commands['convertpassphrase']} "$workGroup"');
        if (jsonDecode(result)['wif'] != null) {
          await chainPrivateKeyAdd(jsonDecode(result)['wif']);
        }
        return result;
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> getCmdMcl(ctx, cmd, pubKey) async {
    print('baglantı kuruluyor...');
    var test = await _currentServer!
        .execute("./komodo/src/komodo-cli -ac_name=MCL $cmd $pubKey");
    print(test);
    return test;
    // var test = await _sshService.getCommandMcl(cmd, pubKey);
    // return test;
  }

  Future<String> onClickCreditIssuerRefresh({int afterDate = 0}) async {
    try {
      var result = await _currentServer!.execute(
          "$pathCli${commands['marmarareceivelist']} $pubKey ${afterDate != 0 ? afterDate : ''}");
      // print(
      //     "$pathCli${commands['marmarareceivelist']} $pubKey ${afterDate != 0 ? afterDate : ''}");
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> creditBearerRequest(
      String pubKey, String amountOrBatonid, int matures) async {
    try {
      var sendtxid;
      if (amountOrBatonid.length == 64) {
        sendtxid = await _currentServer!.execute(
            '''./komodo/src/komodo-cli -ac_name=MCL marmarareceive $pubKey $amountOrBatonid '{"avalcount":"0"}' ''');
      } else {
        sendtxid = await _currentServer!.execute(
            '''./komodo/src/komodo-cli -ac_name=MCL marmarareceive $pubKey $amountOrBatonid MARMARA $matures '{"avalcount":"0"}' ''');
      }

      var rawSendTxId = sendtxid.replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.execute(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        print(sendOnayi);
        if (sendOnayi.length > 2) {
          return sendOnayi.replaceAll("\n", "").replaceAll("\r", "");
        }
      }

      return '';
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<void> startBlockChain() async {
    try {
      String gelen =
          await _currentServer!.execute("$pathCli${commands['addnode']}\n");
      print(gelen);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<String> getInfoBlockChain() async {
    String result;
    try {
      result = await _currentServer!.execute("$pathCli${commands['getinfo']}");
      print(result);
      if (result == "") {
        return "loading block index";
      }
      final contactsBox = Hive.box('sunucular');
      final mclBlockChain =
          contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
      mclBlockChain.getinfo = jsonDecode(result);
      mclBlockChain.refreshTime = DateTime.now();

      var resultStaking =
          await _currentServer!.execute("$pathCli${commands['getgenerate']}");
      mclBlockChain.getGenerate = jsonDecode(resultStaking);

      contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);
      if (jsonDecode(result)['pubkey'] != null) {
        pubKey = jsonDecode(result)['pubkey'];
      }

      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> setGenerateStakingTrue(bool setCmd) async {
    String setString;
    if (setCmd) {
      setString = 'setgenerate0t';
    } else {
      setString = 'setgenerate0f';
    }
    try {
      final contactsBox = Hive.box('sunucular');
      final mclBlockChain =
          contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
      var setStakingTrue =
          await _currentServer!.execute("$pathCli${commands[setString]}");
      print(setStakingTrue);

      var resultStaking =
          await _currentServer!.execute("$pathCli${commands['getgenerate']}");
      mclBlockChain.getGenerate = jsonDecode(resultStaking);

      contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);

      return resultStaking;
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }
}
