import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:mcl/core/components/text/locale_text.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/ui/home/home_viewmodel.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/extension/string_extension.dart';

import 'package:mcl_ui/mcl_ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) {
        if (model.secilenLocalDil == "EN") {
          context.setLocale(context.supportedLocales[0]);
          model.languageChange();
        } else if (model.secilenLocalDil == "TR") {
          context.setLocale(context.supportedLocales[1]);
          model.languageChange();
        } else if (model.secilenLocalDil == "AR") {
          context.setLocale(context.supportedLocales[2]);
          model.languageChange();
        }
        return CommonPage(
          localeKeys: LocaleKeys.project_name,
          appBarWidget: [
            PopupMenuButton(
              icon: Icon(Icons.language),
              onSelected: model.selectPopMenuLang,
              itemBuilder: (BuildContext context) {
                return model.popMenuLanguage.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
            PopupMenuButton(
              onSelected: model.selectPopMenu,
              itemBuilder: (BuildContext context) {
                return model.popMenu.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
          child: ValueListenableBuilder<Box<dynamic>>(
            valueListenable: Hive.box('sunucular').listenable(),
            builder: (context, sunucularBox, widget) {
              var mclBlocChain =
                  Chain(address: '', port: 22, title: '', username: '');
              if (sunucularBox.isNotEmpty) {
                mclBlocChain =
                    sunucularBox.getAt(model.currentPosition.toInt()) as Chain;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    sunucularBox.isEmpty
                        ? Column(
                            children: <Widget>[
                              Text(
                                LocaleKeys.home_yet.locale,
                                style: Theme.of(context).textTheme.title,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  height: 200,
                                  child: Image.asset(
                                    'assets/images/waiting.png',
                                    fit: BoxFit.cover,
                                  )),
                            ],
                          )
                        : Expanded(
                            flex: 5,
                            child: PageView.builder(
                                onPageChanged: (int pageIndex) {
                                  model.pageIndex = pageIndex;
                                },
                                controller: model.pageController,
                                itemCount: sunucularBox.length,
                                itemBuilder: (context, index) => Container(
                                    // margin: EdgeInsets.only(bottom: 24),
                                    width: double.infinity,
                                    // height: 300,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 10),
                                          blurRadius: 10,
                                          color: Colors.black54,
                                          spreadRadius: -5,
                                        )
                                      ],
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF08AEEA),
                                          Color(0xFF2AF598),
                                        ],
                                      ),
                                    ),
                                    child: mclBlocChain.getinfo == null
                                        ? Text(LocaleKeys.home_dash.locale)
                                        : Wrap(
                                            // runSpacing: 10,
                                            spacing: 10,
                                            direction: Axis.vertical,
                                            runAlignment:
                                                WrapAlignment.spaceBetween,
                                            children: [
                                              MclText.subheading(
                                                  'Dashboard: ${model.currentPosition.toInt() + 1}'),
                                              MclText.body(
                                                  "${LocaleKeys.common_chainActive.locale}: ${mclBlocChain.getinfo!['synced'] ? LocaleKeys.common_yes.locale : LocaleKeys.common_no.locale}"),
                                              MclText.body(
                                                  '${LocaleKeys.common_chainSync.locale}: ${mclBlocChain.getinfo!['synced'] ? LocaleKeys.chain_sync.locale : LocaleKeys.chain_async.locale}'),
                                              MclText.body(
                                                  '${LocaleKeys.common_blockCount.locale}: ${mclBlocChain.getinfo!['blocks'] ?? ''}'),
                                              MclText.body(
                                                  '${LocaleKeys.common_allBlockCount.locale}: ${mclBlocChain.getinfo!['longestchain'] ?? ''}'),
                                              MclText.body(
                                                  '${LocaleKeys.chain_currency_unit.locale}: MCL'),
                                              MclText.body(
                                                  '${LocaleKeys.chain_diffuculty.locale}: ${(mclBlocChain.getinfo!['difficulty'] as double).toInt().toString()}'),
                                              MclText.body(
                                                  '${LocaleKeys.chain_status.locale}: ${mclBlocChain.getGenerate!['staking'] ? 'STAKING' : 'MINING'}'),
                                              MclText.subheading(LocaleKeys
                                                  .common_values.locale),
                                              mclBlocChain.marmarainfo != null
                                                  ? MclText.body(
                                                      '${LocaleKeys.common_normal.locale}: ${mclBlocChain.marmarainfo!['myWalletNormalAmount']}')
                                                  : SizedBox(),
                                              mclBlocChain.marmarainfo != null
                                                  ? MclText.body(
                                                      '${LocaleKeys.common_locked.locale}: ${mclBlocChain.marmarainfo!['myActivatedAmount']}')
                                                  : SizedBox(),
                                              mclBlocChain.marmarainfo != null
                                                  ? MclText.body(
                                                      '${LocaleKeys.common_looped.locale}: ${mclBlocChain.marmarainfo!['TotalLockedInLoop']}')
                                                  : SizedBox(),
                                              MclText.body(
                                                  '${LocaleKeys.common_todayPrize.locale}: v1.0'),
                                              MclText.body(
                                                  '${LocaleKeys.common_totalPrize.locale}: v1.0'),
                                              // MclText.body(''),
                                              MclText.body(''),
                                              MclText.caption(
                                                  '${LocaleKeys.common_uptade.locale}: ${DateFormat('dd.MM.yyyy HH:mm').format(mclBlocChain.refreshTime!)}'),
                                            ],
                                          ))),
                          ),
                    Expanded(
                      flex: 1,
                      child: sunucularBox.length == 0
                          ? SizedBox()
                          : DotsIndicator(
                              dotsCount: sunucularBox.length == 0
                                  ? 1
                                  : sunucularBox.length,
                              position: model.currentPosition,
                              decorator: DotsDecorator(
                                activeColor: Colors.white,
                                size: Size(6, 6),
                              ),
                            ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.home_server.locale,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                model.ekliSunucuSayisi == 3
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                                '${LocaleKeys.common_testmaxthree.tr()}')))
                                    : model.startAddNewTransaction(
                                        context,
                                        Chain(
                                            title: '',
                                            username: '',
                                            address: '',
                                            port: 1),
                                        -1);
                              },
                              child: Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(
                    //     bottom: 16,
                    //   ),
                    // ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [MclText.body('fdsf'), MclText.body('fdsf')],
                    // ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.30,
                        child: sunucularBox.isEmpty
                            ? Column(
                                children: <Widget>[
                                  Text(
                                    LocaleKeys.home_addServer.locale,
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                  // SizedBox(
                                  //   height: 20,
                                  // ),
                                  // Container(
                                  //     // height: screenHeightPercentage(context,
                                  //     //     percentage: 0.50),
                                  //     child: Image.asset(
                                  //   'assets/images/waiting.png',
                                  //   fit: BoxFit.cover,
                                  // )),
                                ],
                              )
                            : ListView.separated(
                                itemCount: sunucularBox.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(
                                  height: 15,
                                  color: Colors.grey,
                                ),
                                itemBuilder: (context, index) {
                                  final sunucu =
                                      sunucularBox.getAt(index) as Chain;
                                  return Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    child: Container(
                                      height: 80,
                                      color: index == model.currentPosition
                                          ? Colors.red[200]
                                          : Colors.transparent,
                                      child: ListTile(
                                        onTap: () {
                                          model.pageIndex = index;
                                        },
                                        leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF5B300),
                                            ),
                                            child: Image.asset(
                                                'assets/images/logo.png')),
                                        title: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  sunucu.title,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                (sunucularBox.getAt(index)
                                                                as Chain)
                                                            .marmarainfo !=
                                                        null
                                                    ? Text(
                                                        (sunucularBox.getAt(
                                                                index) as Chain)
                                                            .marmarainfo![
                                                                'myWalletNormalAmount']
                                                            .toString()
                                                            .split('.')[0],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 6),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    sunucu.username,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      (sunucularBox.getAt(index)
                                                                      as Chain)
                                                                  .marmarainfo !=
                                                              null
                                                          ? Text(
                                                              '${(sunucularBox.getAt(index) as Chain).marmarainfo!['myActivatedAmount'].toString().split('.')[0]}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                      // GestureDetector(
                                                      //   onTap: () {
                                                      //     print('test');
                                                      //     model
                                                      //         .passwordServerEnter(
                                                      //             context,
                                                      //             index);
                                                      //   },
                                                      //   child: Icon(
                                                      //     Icons.arrow_right,
                                                      //     color: Colors.green,
                                                      //   ),
                                                      // )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          sunucu.address,
                                        ),
                                        trailing: IconButton(
                                            icon: Icon(
                                              Icons.arrow_right,
                                              size: 40,
                                            ),
                                            color: Theme.of(context).errorColor,
                                            onPressed: () {
                                              model.pageIndex = index;
                                              model.passwordServerEnter(
                                                  context, index);
                                              // model.runStartServer(index);
                                            }),
                                      ),
                                    ),
                                    // actions: <Widget>[
                                    //   IconSlideAction(
                                    //     caption: 'Adres',
                                    //     color: Colors.blue,
                                    //     icon: Icons.archive,
                                    //     onTap: () =>
                                    //         sunucularBox.deleteAt(index),
                                    //   ),
                                    //   IconSlideAction(
                                    //     caption: 'Pubkey',
                                    //     color: Colors.indigo,
                                    //     icon: Icons.share,
                                    //     onTap: () =>
                                    //         sunucularBox.deleteAt(index),
                                    //   ),
                                    // ],
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption:
                                            '${LocaleKeys.common_edit.tr()}',
                                        color: Colors.black45,
                                        icon: Icons.edit,
                                        onTap: () =>
                                            model.startAddNewTransaction(
                                                context, sunucu, index),
                                      ),
                                      IconSlideAction(
                                        caption:
                                            '${LocaleKeys.common_delete.tr()}',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => model.deleteServer(index),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: model.onClickCmd,
          // ),
        );
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}
