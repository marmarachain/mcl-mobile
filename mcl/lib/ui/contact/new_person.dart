import 'package:flutter/material.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:mcl_ui/mcl_ui.dart';

class NewPerson extends StatefulWidget {
  final Function addTx;
  final Person kisi;
  final int kisiIndex;

  NewPerson(this.addTx, this.kisi, this.kisiIndex);

  @override
  _NewPersonState createState() => _NewPersonState();
}

class _NewPersonState extends State<NewPerson> {
  final _nameController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _pubKeyController = TextEditingController();

  // @override
  // void setState(fn) {
  //   // TODO: implement setState
  //   _nameController.text = 'test adi';
  //   super.setState(fn);
  // }

  void _submitData() {
    if (_walletAddressController.text.isEmpty) {
      return;
    }
    final enteredTitle = _nameController.text;
    final walletAddressTitle = _walletAddressController.text;
    final pubKeyTitle = _pubKeyController.text;

    if (enteredTitle.isEmpty ||
        pubKeyTitle.isEmpty ||
        walletAddressTitle.isEmpty) {
      return;
    }

    widget.addTx(
      widget.kisiIndex,
      enteredTitle,
      walletAddressTitle,
      pubKeyTitle,
    );

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kisi.isim != '') {
      _nameController.text =
          _nameController.text == "" ? widget.kisi.isim : _nameController.text;
      _nameController
        ..selection =
            TextSelection.collapsed(offset: _nameController.text.length);
      _walletAddressController.text = _walletAddressController.text == ""
          ? widget.kisi.cuzdanAdresi
          : _walletAddressController.text;
      _walletAddressController
        ..selection = TextSelection.collapsed(
            offset: _walletAddressController.text.length);
      _pubKeyController.text = _pubKeyController.text == ""
          ? widget.kisi.pubKey
          : _pubKeyController.text;
      _pubKeyController
        ..selection =
            TextSelection.collapsed(offset: _pubKeyController.text.length);
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    labelText:
                        '${LocaleKeys.credit_endorser_filter_name.locale}'),

                controller: _nameController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) {
                //   titleInput = val;
                // },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.chain_walletAddress.locale}'),
                controller: _walletAddressController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) => amountInput = val,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Pubkey'),
                controller: _pubKeyController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitData(),
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 3,
                // onChanged: (val) => amountInput = val,
              ),
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                child: Text('${LocaleKeys.home_save.locale}'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(color: Colors.black)),
                onPressed: _submitData,
              ),
              verticalSpaceMedium
            ],
          ),
        ),
      ),
    );
  }
}
