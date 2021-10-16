import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/components/slider/range_price_slider.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/models/transaction.dart';
import 'package:mcl/ui/contact/new_person.dart';
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
                          // print(transactionBox.get(index)['address']);
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
                              // trailing: IconButton(
                              //   icon: Icon(Icons.arrow_right),
                              //   color: Theme.of(context).errorColor,
                              //   onPressed: () => Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => MclDetailView(),
                              //     ),
                              //   ),
                              // ),
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
            Text('Filter'),
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
                // IconButton(
                //     onPressed: () {
                //       viewModel.fetchMinMax();
                //     },
                //     icon: Icon(Icons.check_box_outline_blank))
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
                // IconButton(
                //     onPressed: () {
                //       viewModel.fetchMinMax();
                //     },
                //     icon: Icon(Icons.check_box_outline_blank))
              ],
            ),
            // Card(
            //   child: Column(
            //     children: [
            //       Wrap(
            //         spacing: 10,
            //         children: MclLoopSortValues.values
            //             .map((e) => IconButton(
            //                 padding: EdgeInsets.zero,
            //                 onPressed: () {
            //                   viewModel.fetchSort(e);
            //                 },
            //                 icon: Text(e.rawValue, maxLines: 1)))
            //             .toList(),
            //       ),
            //       Row(
            //         children: [
            //           IconButton(
            //               onPressed: () => viewModel.changeAscending(true),
            //               icon: Icon(Icons.north)),
            //           IconButton(
            //               onPressed: () => viewModel.changeAscending(false),
            //               icon: Icon(Icons.south)),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            MclButton(
              title: "Listele",
              onTap: () {
                print("Transaction List");
                viewModel.onClickListTransactions();
              },
            )
          ],
        ),
      );
}
