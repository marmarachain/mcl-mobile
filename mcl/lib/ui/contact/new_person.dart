import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _pubKeyController = TextEditingController();

  // @override
  // void setState(fn) {
  //   // TODO: implement setState
  //   _titleController.text = 'test adi';
  //   super.setState(fn);
  // }

  void _submitData() {
    print(_titleController.text);
    print(_amountController.text);
    print(_pubKeyController.text);
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final walletAddressTitle = _amountController.text;
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
      _titleController.text = widget.kisi.isim;
      _amountController.text = widget.kisi.cuzdanAdresi;
      _pubKeyController.text = widget.kisi.pubKey;
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

                controller: _titleController,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) {
                //   titleInput = val;
                // },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.chain_walletAddress.locale}'),
                controller: _amountController,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) => amountInput = val,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Pubkey'),
                controller: _pubKeyController,
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
                    primary: Theme.of(context).primaryColor,
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
