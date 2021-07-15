import 'package:flutter/material.dart';
import 'package:mcl/models/chain.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;
  final Chain server;
  final int serverIndex;

  NewTransaction(this.addTx, this.server, this.serverIndex);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController();
  // DateTime? _selectedDate;

  void _submitData() {
    if (_addressController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final enteredUsername = _usernameController.text;
    final enteredAddress = _addressController.text;
    final enteredPort = int.parse(_portController.text);

    if (enteredTitle.isEmpty ||
        enteredUsername.isEmpty ||
        enteredAddress.isEmpty ||
        enteredPort <= 0) {
      return;
    }

    widget.addTx(enteredTitle, enteredUsername, enteredAddress, enteredPort,
        widget.serverIndex);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serverIndex != -1) {
      _titleController.text = widget.server.title;
      _usernameController.text = widget.server.username;
      _addressController.text = widget.server.address;
      _portController.text = widget.server.port.toString();
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Text('${LocaleKeys.home_serverAdd.locale}')),
              Divider(height: 2, thickness: 2),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.home_serverName.locale}'),
                controller: _titleController,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) {
                //   titleInput = val;
                // },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.home_username.locale}'),
                controller: _usernameController,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) {
                //   titleInput = val;
                // },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.home_ipaddress.locale}'),
                controller: _addressController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submitData(),
                // onChanged: (val) => amountInput = val,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: '${LocaleKeys.home_portNumber.locale}'),
                controller: _portController..text = '22',
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submitData(),
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
            ],
          ),
        ),
      ),
    );
  }
}
