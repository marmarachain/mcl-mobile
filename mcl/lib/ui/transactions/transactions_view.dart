import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/models/transaction.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mcl/core/extension/context_extension.dart';
import 'package:mcl/core/extension/int_date_extension.dart';

import 'transactions_viewmodel.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Person? bosPerson = Person(isim: '', cuzdanAdresi: '', pubKey: '');
    return ViewModelBuilder<TransactionsViewModel>.reactive(
      builder: (context, model, _) => CommonPage(
        backButton: model.backPop,
        localeKeys: LocaleKeys.contact_name,
        appBarWidget: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => buildBottomSheetBody(context, model));
            },
          )
        ],
        child: ValueListenableBuilder<Box<dynamic>>(
            valueListenable: Hive.box('transactions').listenable(),
            builder: (context, transactionBox, widget) {
              return Container(
                // height: screenHeightPercentage(context, percentage: 0.8),
                child: transactionBox.isEmpty
                    ? Center(
                        child: Text(
                          '${LocaleKeys.contact_yet.tr()}',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, index) {
                          var transaction =
                              transactionBox.get(index) as Transaction;
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 5,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    transaction.category == 'generate'
                                        ? Colors.red
                                        : transaction.category == 'send'
                                            ? Colors.blue
                                            : Colors.green,
                                radius: 30,
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: FittedBox(
                                    child:
                                        Icon(transaction.category == 'generate'
                                            ? Icons.monetization_on
                                            : transaction.category == 'send'
                                                ? Icons.send
                                                : Icons.get_app),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${transaction.category} ${transaction.amount}',
                              ),
                              subtitle: Text(
                                transaction.blocktime.toConvertDateTime,
                              ),
                            ),
                          );
                        },
                        itemCount: transactionBox.length,
                      ),
              );
            }),
      ),
      viewModelBuilder: () => TransactionsViewModel(),
    );
  }

  Widget buildBottomSheetBody(
          BuildContext context, TransactionsViewModel viewModel) =>
      Padding(
        padding: context.paddingLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.common_filter.locale),
            Divider(height: 2, thickness: 2),
            Row(
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Slider(
                        label: "${viewModel.valueSlider!.toInt()}",
                        min: 10,
                        max: 100,
                        divisions: 9,
                        value: viewModel.valueSlider!,
                        onChanged: (selection) {
                          setState(() {
                            viewModel.changeSlider(selection);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Slider(
                        label: "${viewModel.valueSliderStart!.toInt()}",
                        min: 0,
                        max: 3000,
                        divisions: 10,
                        value: viewModel.valueSliderStart!,
                        onChanged: (selection) {
                          setState(() {
                            viewModel.changeSliderStart(selection);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            MclButton(
              title: LocaleKeys.common_list.locale,
              onTap: () {
                inspect("Transaction List");
                viewModel.onClickListTransactions();
              },
            )
          ],
        ),
      );
}
