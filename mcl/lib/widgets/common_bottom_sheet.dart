import 'package:flutter/material.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/core/extension/string_extension.dart';

class CommonBottomSheet extends StatefulWidget {
  final Function addTx;
  final String privateKey;
  final String title;

  CommonBottomSheet(this.addTx, this.privateKey, this.title);

  @override
  _CommonBottomSheetState createState() => _CommonBottomSheetState();
}

class _CommonBottomSheetState extends State<CommonBottomSheet> {
  final _titleController = TextEditingController();

  // DateTime? _selectedDate;

  void _submitData() {
    if (_titleController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty) {
      return;
    }

    // enteredTitle yerine privateKey olacak
    widget.addTx(
      context,
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
              Align(alignment: Alignment.topLeft, child: Text(widget.title)),
              Divider(height: 2, thickness: 2),
              SizedBox(
                height: 10,
              ),
              SelectableText(widget.privateKey),
            ],
          ),
        ),
      ),
    );
  }
}
