import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class EnteredServer extends StatefulWidget {
  final Function addTx;

  EnteredServer(this.addTx);

  @override
  _EnteredServerState createState() => _EnteredServerState();
}

class _EnteredServerState extends State<EnteredServer> {
  final _titleController = TextEditingController();
  bool? _passwordVisible = false;

  // DateTime? _selectedDate;

  void _submitData() {
    if (_titleController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty) {
      return;
    }

    widget.addTx(
      enteredTitle,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Align(
                alignment: Alignment.topLeft,
                child: Text("${LocaleKeys.home_serverConnect.locale}")),
            Divider(height: 2, thickness: 2),
            SizedBox(
              height: 10,
            ),
            TextField(
              obscureText: !_passwordVisible!,
              decoration: InputDecoration(
                  labelText: '${LocaleKeys.home_serverPassword.locale}',
                  suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible!
                            ? Icons.visibility
                            : Icons.visibility_off,
                        semanticLabel: _passwordVisible!
                            ? 'hide password'
                            : 'show password',
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible!;
                        });
                      })),
              controller: _titleController,
              onSubmitted: (_) => _submitData(),
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            SizedBox(
              height: 18,
            ),
            ElevatedButton(
              child: Text('${LocaleKeys.home_serverConOk.locale}'),
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  textStyle: TextStyle(color: Colors.black)),
              onPressed: _submitData,
            ),
          ],
        ),
      ),
    );
  }
}
