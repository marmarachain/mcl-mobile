import 'package:flutter/material.dart';

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

  void _submitData() {
    if (_titleController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty) {
      return;
    }

    // will be privateKey instead of enteredTitle
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
