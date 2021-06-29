import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/ui/contact/new_person.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mcl/core/extension/string_extension.dart';

class ContactViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Function? deneme(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) {
  //       return GestureDetector(
  //         onTap: () {},
  //         child: NewPerson(addNewPerson),
  //         behavior: HitTestBehavior.opaque,
  //       );
  //     },
  //   );
  // }

  void deneme() {
    print('APP BAR BUTTON');
  }

  void addNewPerson(
      int kisiIndex, String txName, String txWalletAddress, String txpubKey) {
    final newTx = Person(
      isim: txName,
      cuzdanAdresi: txWalletAddress,
      pubKey: txpubKey,
      // id: DateTime.now().toString(),
    );
    final contactsBox = Hive.box('kisiler');
    if (kisiIndex == -1) {
      contactsBox.add(newTx);
    } else {
      contactsBox.putAt(kisiIndex, newTx);
    }

    // final newContact = Contact(_name, int.parse(_age));
    _navigationService.back();
    // setState(() {
    //   _userTransactions.add(newTx);
    // });
  }

  void panoyaKopyalandi(BuildContext ctx, String copyText, String messageDown) {
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content:
            Text('$messageDown ${LocaleKeys.chain_copiedToClipboard.locale}')));
  }

  Future<void> deletePerson(int indexPerson) async {
    // kisilerBox.deleteAt(index)
    final contactsBox = Hive.box('kisiler');
    var kisi = contactsBox.getAt(indexPerson);

    var onay = await _dialogService.showConfirmationDialog(
        title: 'Kişi Silme',
        description:
            '${(kisi as Person).isim} \nSilmek istediğinize emin misiniz?',
        cancelTitle: '${LocaleKeys.common_no.locale}',
        confirmationTitle: '${LocaleKeys.common_yes.locale}');
    print(onay!.confirmed.toString());
    if (onay.confirmed) {
      contactsBox.deleteAt(indexPerson);
    }
  }

  void backPop() {
    _navigationService.back();
  }
}
