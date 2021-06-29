import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class CirantaSearchRefresh extends StatefulWidget {
  final Function addTx;

  CirantaSearchRefresh(this.addTx);

  @override
  _CirantaSearchRefreshState createState() => _CirantaSearchRefreshState();
}

class _CirantaSearchRefreshState extends State<CirantaSearchRefresh> {
  final _amountControllerFirst = TextEditingController();
  final _amountControllerLast = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedLastDate;
  TimeOfDay? _selectedLastTime;

  bool dateLimit = true;
  bool amountLimit = true;

  void _submitData() {
    if (dateLimit && amountLimit) {
      widget.addTx(0, 0, 0.0, 0.0);
      Navigator.of(context).pop();
      return;
    }
    if (!amountLimit && _amountControllerFirst.text.isEmpty) {
      return;
    }
    if (!amountLimit && _amountControllerLast.text.isEmpty) {
      return;
    }

    // if (enteredAmountFirst <= 0 ||
    //     enteredAmountLast <= 0 ||
    //     _selectedDate == null ||
    //     _selectedLastDate == null) {
    //   return;
    // }

    if (!dateLimit && _selectedDate == null) {
      return;
    }
    if (!dateLimit && _selectedLastDate == null) {
      return;
    }

    var startTime = DateTime(2020, 01, 24, 10, 15);
    var currentTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);

    var diffTime = currentTime.difference(startTime).inMinutes;
    print(diffTime);

    print(DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute));
    print(_selectedTime);
    print(_selectedLastDate);
    print(_selectedLastTime);
    var startTime2 = DateTime(2020, 01, 24, 10, 15);
    var currentTime2 = DateTime(
        _selectedLastDate!.year,
        _selectedLastDate!.month,
        _selectedLastDate!.day,
        _selectedLastTime!.hour,
        _selectedLastTime!.minute);

    var diffTime2 = currentTime2.difference(startTime2).inMinutes;
    print(diffTime2);

    if (!dateLimit && amountLimit) {
      widget.addTx(diffTime, diffTime2, 0.0, 0.0);
      Navigator.of(context).pop();
      return;
    }
    final enteredAmountFirst = double.parse(_amountControllerFirst.text);
    final enteredAmountLast = double.parse(_amountControllerLast.text);
    if (dateLimit && !amountLimit) {
      widget.addTx(0, 0, enteredAmountFirst, enteredAmountLast);
      Navigator.of(context).pop();
      return;
    }

    widget.addTx(diffTime, diffTime2, enteredAmountFirst, enteredAmountLast);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
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
        _selectedDate = pickedDate;
      });
    });
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _selectedTime = value;
      });
    });
    print('...');
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
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${LocaleKeys.credit_endorser_matures.locale}'),
                Spacer(),
                dateLimit
                    ? Text('${LocaleKeys.credit_endorser_all.locale}')
                    : Spacer(),
                Switch(
                    value: dateLimit,
                    onChanged: (_) {
                      setState(() {
                        dateLimit = !dateLimit;
                      });
                    }),
              ],
            ),
            !dateLimit
                ? Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? '${LocaleKeys.credit_endorser_maturesFirst.locale}'
                                : '${LocaleKeys.credit_endorser_selectedMaturesFirst.locale}: ${DateFormat.yMd().format(_selectedDate!)}',
                          ),
                        ),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${LocaleKeys.credit_endorser_select.locale}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _presentDatePicker,
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            !dateLimit
                ? Container(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedLastDate == null
                                ? '${LocaleKeys.credit_endorser_maturesLast.locale}'
                                : '${LocaleKeys.credit_endorser_selectedMaturesLast.locale}: ${DateFormat.yMd().format(_selectedLastDate!)}',
                          ),
                        ),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${LocaleKeys.credit_endorser_select.locale}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _presentLastDatePicker,
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            // Spacer(),
            SizedBox(
                height: 1,
                child: Container(
                  color: Colors.grey,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${LocaleKeys.credit_endorser_filter_amount.locale}'),
                Spacer(),
                amountLimit
                    ? Text('${LocaleKeys.credit_endorser_all.locale}')
                    : Spacer(),
                Switch(
                    value: amountLimit,
                    onChanged: (_) {
                      setState(() {
                        amountLimit = !amountLimit;
                      });
                    }),
              ],
            ),
            !amountLimit
                ? Wrap(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                              labelText:
                                  '${LocaleKeys.credit_endorser_minAmount.locale}'),
                          controller: _amountControllerFirst,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _submitData(),
                          // onChanged: (val) {
                          //   titleInput = val;
                          // },
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextField(
                          decoration: InputDecoration(
                              labelText:
                                  '${LocaleKeys.credit_endorser_maxAmount.locale}'),
                          controller: _amountControllerLast,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _submitData(),
                          // onChanged: (val) => amountInput = val,
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
            ElevatedButton(
              child: Text('${LocaleKeys.common_refresh.locale}'),
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
