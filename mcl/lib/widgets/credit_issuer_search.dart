import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class IssuerSearchRefresh extends StatefulWidget {
  final Function addTx;

  IssuerSearchRefresh(this.addTx);

  @override
  _IssuerSearchRefreshState createState() => _IssuerSearchRefreshState();
}

class _IssuerSearchRefreshState extends State<IssuerSearchRefresh> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedLastDate;
  TimeOfDay? _selectedLastTime;

  bool dateLimit = false;
  bool amountLimit = false;

  void _submitData() {
    if (_selectedDate == null) {
      return;
    }
    var today = new DateTime.now();
    print(today);
    var selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, today.hour, today.minute);
    var diffTimeMinute = today.difference(selectedDate).inMinutes;

    widget.addTx(diffTimeMinute);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentLastDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2023),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedLastDate = pickedDate;
      });
    });
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _selectedLastTime = value;
      });
    });
    print('...');
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: Icon(Icons.keyboard_arrow_left),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  Text('${LocaleKeys.credit_issuer_dateAfterRequest.locale}'),
                ],
              ),
              Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? ''
                            : '${LocaleKeys.credit_SelectedDate.locale}: ${DateFormat.yMd().format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      // textColor: Theme.of(context).primaryColor,
                      style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: Text(
                        '${LocaleKeys.credit_SelectDate.locale}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
              ),
              // Spacer(),

              ElevatedButton(
                child: Text('${LocaleKeys.common_refresh.locale}'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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
