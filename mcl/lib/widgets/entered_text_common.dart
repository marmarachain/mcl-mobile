import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class EnteredTextCommon extends StatefulWidget {
  final Function addTx;

  EnteredTextCommon(this.addTx);

  @override
  _EnteredTextCommonState createState() => _EnteredTextCommonState();
}

class _EnteredTextCommonState extends State<EnteredTextCommon> {
  final _titleController = TextEditingController();

  void _submitData() {
    print(_titleController.text.length);
    if (_titleController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;

    if (enteredTitle.length != 52) {
      return;
    }

    widget.addTx(
      enteredTitle,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Text("${LocaleKeys.chain_importPrivate.locale}")),
              Divider(height: 2, thickness: 2),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Private Key',
                ),
                controller: _titleController,
                onSubmitted: (_) => _submitData(),
              ),
              SizedBox(
                height: 18,
              ),
              ElevatedButton(
                child: Text('${LocaleKeys.home_add.locale}'),
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(color: Colors.black)),
                onPressed: _submitData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
