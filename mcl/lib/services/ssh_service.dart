import 'dart:convert';
import 'dart:developer';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/utils/commands.dart';

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
        _currentServer0!.close();
        _currentServer0 = null;
        break;
      case 1:
        _currentServer1!.close();
        _currentServer1 = null;
        break;
      case 2:
        _currentServer2!.close();
        _currentServer2 = null;
        break;
      default:
    }
    mclSelectedBlocChainIndex = -1;
    _currentServer!.close();
    _currentServer = null;
  }

  Future<String> connectSshAccount(String passServer) async {
    log.v('Connect ssh');

    final dashboardBox = Hive.box('dashboard');
    int indexServer = dashboardBox.get('selected_server_index');

    final sunucularBox = Hive.box('servers');
    final sunucu = sunucularBox.getAt(indexServer) as Chain;

    var hostValue = sunucu.address;
    var portValue = sunucu.port;
    var usernameValue = sunucu.username;
    var passwordValue = passServer;

    try {
      final sshAccount = SSHClient(
        await SSHSocket.connect(hostValue, portValue),
        username: usernameValue,
        onPasswordRequest: () => passwordValue,
      );

      inspect(sshAccount);

      if (!sshAccount.isClosed) {
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
        _currentServer = sshAccount;

        var mclFile =
            await _currentServer!.run('find ~/.komodo -iname "MCL" -type d');
        print(utf8.decode(mclFile));
        if (utf8.decode(mclFile) == '') {
          chainWork = false;
          return 'MCL no';
        }
        var cliFileIs = await _currentServer!.run('find / -iname "komodo-cli"');
        print(utf8.decode(cliFileIs));
        var cliFile = utf8.decode(cliFileIs);
        if (cliFile != '') {
          var newPath = cliFile.replaceAll("\n", "").replaceAll("\r", "");
          pathCli = newPath
                  .split('/')
                  .sublist(0, newPath.split('/').length - 1)
                  .join('/') +
              '/';

          var komodoRunPath = newPath
                  .split('/')
                  .sublist(0, newPath.split('/').length - 1)
                  .join('/') +
              '/';
          pathCli = komodoRunPath;
        }
        var test_one =
            await _currentServer!.run("$pathCli${commands['getinfo']}");
        var test = utf8.decode(test_one);
        inspect(test);
        Map<String, dynamic> data = jsonDecode(test);
        inspect(data);

        if (test != '') {
          if (jsonDecode(test)['pubkey'] != null) {
            pubKey = jsonDecode(test)['pubkey'];
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
      var result = await _currentServer!.run(
          "$pathCli${commands['marmaraholderloops']} $firstHeight $lastHeight $minAmount $maxAmount $_pubKey");

      return utf8.decode(result);
    } on PlatformException catch (e) {
      inspect('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<void> marmaraInfoBlocChain() async {
    try {
      // result = await _currentServer.connect();
      var result = await _currentServer!
          .run("$pathCli${commands['marmarainfo']} $pubKey");

      final contactsBox = Hive.box('servers');
      final mclBlockChain =
          contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
      mclBlockChain.marmarainfo = jsonDecode(utf8.decode(result));
      contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<String> krediIstegiOnaylama(String receivePubKey, String txId) async {
    try {
      var sendtxid = await _currentServer!.run(
          '''$pathCli${commands['marmaraissue']} $receivePubKey '{"avalcount":"0", "autosettlement":"true", "autoinsurance":"true", "disputeexpires":"0", "EscrowOn":"false", "BlockageAmount":"0" }' $txId''');

      var rawSendTxId =
          utf8.decode(sendtxid).replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.run(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        inspect(sendOnayi);
        if (sendOnayi.length > 2) {
          return utf8
              .decode(sendOnayi)
              .replaceAll("\n", "")
              .replaceAll("\r", "");
        }
      }

      return '';
    } on PlatformException catch (e) {
      inspect('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> cuzdanAktifleme(int amount) async {
    try {
      var sendtxid = await _currentServer!
          .run("$pathCli${commands['marmaralock']} $amount");

      var rawSendTxId =
          utf8.decode(sendtxid).replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.run(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        print(sendOnayi);
        if (sendOnayi.length > 2) {
          return utf8
              .decode(sendOnayi)
              .replaceAll("\n", "")
              .replaceAll("\r", "");
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
      var sendtxidRun = await _currentServer!
          .run("$pathCli${commands['marmaraunlock']} $amount");
      var sendtxid = utf8.decode(sendtxidRun);
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
        var sendOnayiRun = await _currentServer!
            .run("$pathCli${commands['sendrawtransaction']} '$rawSendTxId'");

        var sendOnayi = utf8.decode(sendOnayiRun);
        inspect(sendOnayi);
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
      var sendOnayiRun = await _currentServer!.run(
          "./komodo/src/komodo-cli -ac_name=MCL sendrawtransaction '$gelensendTxId'");
      var sendOnayi = utf8.decode(sendOnayiRun);
      inspect(sendOnayi);
      if (sendOnayi.length > 2) {
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      inspect('Error: ${e.code}\nError Message: ${e.message}');
      return false;
    }
  }

  Future<String?> onClickCirantaDonguDetay(String batonId) async {
    try {
      var result = await _currentServer!
          .run("$pathCli${commands['marmaracreditloop']}$batonId");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      inspect('Error: ${e.code}\nError Message: ${e.message}');
    }
    return null;
  }

  Future<String> receiveSend(String receiverAddress, double amount) async {
    try {
      var sendtxid = await _currentServer!.run(
          '$pathCli${commands['sendtoaddress']} "$receiverAddress" $amount');

      var rawSendTxId =
          utf8.decode(sendtxid).replaceAll("\n", "").replaceAll("\r", "");

      if (rawSendTxId.length == 64) {
        return rawSendTxId;
      }

      return '';
    } on PlatformException catch (e) {
      inspect('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  bool isServerConnect(int serverIndex) {
    print(chainWork);
    try {
      switch (serverIndex) {
        case 0:
          var result = _currentServer0!.shell();
          _currentServer = _currentServer0;
          mclSelectedBlocChainIndex = 0;
          // pathCli = _currentServer!.pathMclCli;
          // print(result);
          return true;
        // break;
        case 1:
          var result = _currentServer1!.shell();
          _currentServer = _currentServer1;
          mclSelectedBlocChainIndex = 1;
          // pathCli = _currentServer!.pathMclCli;
          // print(result);
          return true;
        case 2:
          var result = _currentServer2!.shell();
          _currentServer = _currentServer2;
          mclSelectedBlocChainIndex = 2;
          // pathCli = _currentServer!.pathMclCli;
          // print(result);
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> chainViewModelStart() async {
    var result;

    try {
      result = await _currentServer!
          .run("$pathCli${commands['getaddressesbyaccount']} ''");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainViewAddressValidation(String walletAddress) async {
    var result;
    try {
      result = await _currentServer!
          .run("$pathCli${commands['validateaddress']} $walletAddress");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainViewAddressBalance(String walletAddress) async {
    var result;

    try {
      result = await _currentServer!.run(
          """komodo/src/komodo-cli -ac_name=MCL getaddressbalance '{"addresses":["$walletAddress"]}'""");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainStop() async {
    var result;
    try {
      result = await _currentServer!.run("$pathCli${commands['stop']}");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainStart(String gelenPuKey) async {
    var result;
    try {
      result = await _currentServer!
          .run("$pathCli${commands['start']}$gelenPuKey &");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainPrivateKeyShow(String getWalletAddress) async {
    inspect(pubKey);
    var searchWalletAddress;
    if (getWalletAddress == '') {
      searchWalletAddress = walletAddress;
    } else {
      searchWalletAddress = getWalletAddress;
    }
    var result;
    try {
      result = await _currentServer!
          .run("$pathCli${commands['dumpprivkey']} $searchWalletAddress &");
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainPrivateKeyAdd(String privateKey) async {
    try {
      var findWalletAddress = await _currentServer!
          .run("$pathCli${commands['importprivkey']} $privateKey");
      var checkAddress = await _currentServer!
          .run("$pathCli${commands['validateaddress']} $findWalletAddress &");
      // print(utf8.decode(checkAddress)['isvalid']);
      // print(jsonDecode(checkAddress));
      if (jsonDecode(utf8.decode(checkAddress))['isvalid']) {
        return findWalletAddress.toString();
      } else {
        return '';
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  Future<String> chainNewWalletAddressCreate(String workGroup) async {
    var result;
    try {
      if (workGroup == '') {
        var newwalletaddress =
            await _currentServer!.run("$pathCli${commands['getnewaddress']}");
        result = await _currentServer!
            .run("$pathCli${commands['dumpprivkey']} $newwalletaddress");
        var checkAddress = await _currentServer!
            .run("$pathCli${commands['validateaddress']} $newwalletaddress &");
        print(jsonDecode(utf8.decode(checkAddress))['isvalid']);
        print(jsonDecode(utf8.decode(checkAddress)));
        if (jsonDecode(utf8.decode(checkAddress))['isvalid']) {
          return jsonDecode(utf8.decode(checkAddress));
        } else {
          return '';
        }
      } else {
        result = await _currentServer!
            .run('$pathCli${commands['convertpassphrase']} "$workGroup"');
        if (jsonDecode(utf8.decode(result))['wif'] != null) {
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
        .run("./komodo/src/komodo-cli -ac_name=MCL $cmd $pubKey");
    // print(test);
    return utf8.decode(test);
    // var test = await _sshService.getCommandMcl(cmd, pubKey);
    // return test;
  }

  Future<String> onClickCreditIssuerRefresh({int afterDate = 0}) async {
    try {
      var result = await _currentServer!.run(
          "$pathCli${commands['marmarareceivelist']} $pubKey ${afterDate != 0 ? afterDate : ''}");
      return utf8.decode(result);
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
        sendtxid = await _currentServer!.run(
            '''./komodo/src/komodo-cli -ac_name=MCL marmarareceive $pubKey $amountOrBatonid '{"avalcount":"0"}' ''');
      } else {
        sendtxid = await _currentServer!.run(
            '''./komodo/src/komodo-cli -ac_name=MCL marmarareceive $pubKey $amountOrBatonid MARMARA $matures '{"avalcount":"0"}' ''');
      }

      var rawSendTxId =
          utf8.decode(sendtxid).replaceAll("\n", "").replaceAll("\r", "");
      Map jsonHex = jsonDecode(rawSendTxId);
      if (jsonHex['result'] == 'success') {
        var sendOnayi = await _currentServer!.run(
            "$pathCli${commands['sendrawtransaction']} '${jsonHex['hex']}'");
        print(utf8.decode(sendOnayi));
        if (sendOnayi.length > 2) {
          return utf8
              .decode(sendOnayi)
              .replaceAll("\n", "")
              .replaceAll("\r", "");
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
      var gelen = await _currentServer!.run("$pathCli${commands['addnode']}\n");
      print(gelen);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<String> getInfoBlockChain() async {
    var result;
    try {
      result = await _currentServer!.run("$pathCli${commands['getinfo']}");
      // print(result);
      if (result == "") {
        return "loading block index";
      }
      final contactsBox = Hive.box('servers');
      final mclBlockChain =
          contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
      mclBlockChain.getinfo = jsonDecode(utf8.decode(result));
      mclBlockChain.refreshTime = DateTime.now();

      var resultStaking =
          await _currentServer!.run("$pathCli${commands['getgenerate']}");
      mclBlockChain.getGenerate = jsonDecode(utf8.decode(resultStaking));

      contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);
      if (jsonDecode(utf8.decode(result))['pubkey'] != null) {
        pubKey = jsonDecode(utf8.decode(result))['pubkey'];
      }

      return utf8.decode(result);
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
      final contactsBox = Hive.box('servers');
      final mclBlockChain =
          contactsBox.getAt(mclSelectedBlocChainIndex!) as Chain;
      var setStakingTrue =
          await _currentServer!.run("$pathCli${commands[setString]}");
      print(setStakingTrue);

      var resultStaking =
          await _currentServer!.run("$pathCli${commands['getgenerate']}");
      mclBlockChain.getGenerate = jsonDecode(utf8.decode(resultStaking));

      contactsBox.putAt(mclSelectedBlocChainIndex!, mclBlockChain);

      return utf8.decode(resultStaking);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }

  // LIST TRANSACTIONS START
  Future<String> onClickListTransactions(
      {int count = 10, int start = 0}) async {
    try {
      var result = await _currentServer!
          .run("$pathCli${commands['listtransactions']} $count $start");
      print(result);
      return utf8.decode(result);
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      return '';
    }
  }
  // LIST TRANSACTIONS STOP
}
