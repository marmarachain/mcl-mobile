import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/ui/chain/chain_viewmodel.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/extension/string_extension.dart';
import 'package:mcl/core/extension/context_extension.dart';

class ChainView extends StatelessWidget {
  // final String? getPubKeyInfo;
  const ChainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChainViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      builder: (context, model, child) => CommonPage(
        localeKeys: LocaleKeys.chain_name,
        backButton: () {
          model.navigatorHomeScreen();
        },
        appBarWidget: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              model.chainLogout();
            },
          )
        ],
        appBarFunction: () {},
        child:
            // model.isBusy
            //     ? Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     :
            SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 24),
                    width: double.infinity,
                    height: 150,
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
                    child: ValueListenableBuilder<Box<dynamic>>(
                      valueListenable: Hive.box('sunucular').listenable(),
                      builder: (context, mclBlocBox, widget) {
                        var mclBlocChain = Chain(
                            address: '', port: 22, title: '', username: '');
                        if (mclBlocBox.isNotEmpty) {
                          mclBlocChain = mclBlocBox.getAt(
                              model.secilenBlokZincirIndex.toInt()) as Chain;
                        }

                        return mclBlocChain.getinfo == null
                            ? Text("${LocaleKeys.chain_description.locale}")
                            : model.isBusy
                                ? Center(child: CircularProgressIndicator())
                                : Wrap(
                                    spacing: 8,
                                    direction: Axis.vertical,
                                    runAlignment: WrapAlignment.spaceBetween,
                                    children: [
                                      // MclText.subheading('Dashboard: 1'),
                                      MclText.body(
                                          '${LocaleKeys.chain_activity.locale}: ${mclBlocChain.getinfo!['synced'] ? "${LocaleKeys.common_yes.locale}" : "${LocaleKeys.common_no.locale}"}'),
                                      MclText.body(
                                          '${LocaleKeys.chain_chainSync.locale}: ${mclBlocChain.getinfo!['synced'] ? "${LocaleKeys.chain_sync.locale}" : "${LocaleKeys.chain_async.locale}"}'),
                                      MclText.body(
                                          '${LocaleKeys.chain_number_block.locale}: ${mclBlocChain.getinfo!['blocks'] ?? ''}'),
                                      MclText.body(
                                          '${LocaleKeys.chain_all_block.locale}: ${mclBlocChain.getinfo!['longestchain'] ?? ''}'),
                                      MclText.body(
                                          '${LocaleKeys.chain_currency_unit.locale}: MCL'),
                                      MclText.body(
                                          '${LocaleKeys.chain_diffuculty.locale}: ${(mclBlocChain.getinfo!['difficulty'] as double).toInt().toString()}'),
                                      MclText.body(
                                          '${LocaleKeys.chain_status.locale}: ${mclBlocChain.getGenerate!['staking'] ? 'STAKING' : mclBlocChain.getGenerate!['generate'] ? 'MINING' : 'PASİF'}'),
                                      Row(
                                        children: [
                                          MclText.body(
                                              '${LocaleKeys.chain_staking.locale}: '),
                                          Switch(
                                              value: mclBlocChain
                                                  .getGenerate!['staking'],
                                              onChanged: (bool deger) {
                                                model.switchStateStaking =
                                                    deger;
                                              })
                                        ],
                                      )
                                    ],
                                  );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: MclButton(
                    busy: model.isBusy,
                    leading: Icon(
                      Icons.refresh_outlined,
                      color: kcVeryLightGreyColor,
                    ),
                    title: '${LocaleKeys.common_refresh.locale}',
                    onTap: () {
                      model.stateBlockChain();
                    },
                  ),
                ),
                // Text(model.cmdLineResult),
                Align(
                  alignment: Alignment.topLeft,
                  child: MclText.body('${LocaleKeys.chain_myWallets.locale}'),
                ),
                SizedBox(
                  height: 10,
                ),
                ExpansionPanelList.radio(
                  initialOpenPanelValue: 1,
                  children:
                      model.dataWallet.map<ExpansionPanelRadio>((Item item) {
                    return ExpansionPanelRadio(
                        value: item.id,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return RadioListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${item.id}. ${LocaleKeys.chain_myWallet.locale}"),
                                Row(
                                  children: [
                                    // item.expandedValue ==
                                    //         model.activeChainWalletAddress
                                    //     ? Icon(
                                    //         Icons.check,
                                    //         color: Colors.red[400],
                                    //       )
                                    //     : SizedBox(),
                                    IconButton(
                                        icon:
                                            Icon(Icons.account_balance_wallet),
                                        onPressed: () => model.copiedToClipboard(
                                            context,
                                            item.expandedValue,
                                            '${LocaleKeys.chain_walletAddress.locale}')),
                                    IconButton(
                                        icon: Icon(Icons.vpn_key),
                                        onPressed: () => model.copiedToClipboard(
                                            context,
                                            item.headerValue,
                                            '${LocaleKeys.chain_pubKey.locale}'))
                                  ],
                                )
                              ],
                            ),
                            groupValue: model.character,
                            onChanged: (String? value) {
                              model.character = value!;
                            },
                            value: item.headerValue,
                          );
                        },
                        body: ListTile(
                            title: Text(item.expandedValue),
                            subtitle: Text(item.headerValue),
                            // trailing: Row(
                            //   children: [
                            //     Icon(Icons.delete),
                            //     Icon(Icons.keyboard)
                            //   ],
                            // ),
                            onTap: () {
                              // _data
                              //     .removeWhere((Item currentItem) => item == currentItem);
                            }));
                  }).toList(),
                ),
                SizedBox(
                  height: 18,
                ),
                // Text(model.cmdLineResult),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      // style: ElevatedButton.styleFrom(
                      //     primary: Theme.of(context).secondaryHeaderColor,
                      //     textStyle: TextStyle(color: Colors.black)),
                      onPressed: model.buttonStart
                          ? () => model.onClickMclStart()
                          : null,
                      icon: Icon(Icons.play_arrow_outlined),
                      label: Text('${LocaleKeys.chain_start.locale}'),
                    ),
                    ElevatedButton.icon(
                      onPressed: !model.buttonStart
                          ? () => model.onClickChainStop()
                          : null,
                      icon: Icon(Icons.pause_circle_filled_outlined),
                      label: Text('${LocaleKeys.chain_stop.locale}'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                model.pubKeyIs
                    ? SizedBox()
                    : SizedBox(
                        height: 30,
                        width: 250.0,
                        child: Container(
                          // color: Colors.yellow,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Center(
                              child: AnimatedTextKit(
                                totalRepeatCount: 10,
                                animatedTexts: [
                                  FadeAnimatedText(
                                      '${LocaleKeys.chain_workWithoutPubkey.locale}!'),
                                  FadeAnimatedText(
                                      '${LocaleKeys.chain_stopChain.locale}!!'),
                                  FadeAnimatedText(
                                      '${LocaleKeys.chain_startPubkey.locale}!!!'),
                                ],
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                    onPressed: () {
                      // model.onClickNewWalletAddressCreate(context);
                      // model.workGroupController.clear();
                      // model.workGroupControllerEqual.clear();
                      // model.newwalletAddress.clear();
                      // model.newPubkey.clear();
                      showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              buildBottomSheetBody(context, model));
                    },
                    child: Text('${LocaleKeys.chain_createNewAddress.locale}')),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          model.onClickPrivateKeyAdd(context);
                        },
                        child:
                            Text('${LocaleKeys.chain_importPrivate.locale}')),
                    OutlinedButton(
                        onPressed: () {
                          model.onClickPrivateKeyShow(context);
                        },
                        child: Text("${LocaleKeys.chain_seePrivate.locale}")),
                  ],
                ),
                // Text(
                //   model.cmdLineResult,
                //   style: TextStyle(color: Colors.white),
                // ),
              ],
            ),
          ),
        ),
      ),
      onModelReady: (viewmodel) => viewmodel.onClickCmd(),
      viewModelBuilder: () => ChainViewModel(),
    );
  }

  Widget buildBottomSheetBody(BuildContext context, ChainViewModel viewModel) =>
      SingleChildScrollView(
        child: Padding(
          padding: context.paddingLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${LocaleKeys.chain_createNewAddress.locale}'),
              Divider(height: 2, thickness: 2),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     // model.switchStateEndorser
              //     //     ? LocaleText(
              //     //         value:
              //     //             LocaleKeys.credit_endorser_endorsement_request_list)
              //     //     : LocaleText(
              //     //         value: LocaleKeys.credit_endorser_bearer_loops),
              //     Switch(
              //         value: viewModel.switchWordGroup,
              //         onChanged: (bool deger) {
              //           viewModel.switchWordGroup = deger;
              //         })
              //   ],
              // ),
              TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${LocaleKeys.chain_wordGroup.locale}',
                  ),
                  controller: viewModel.workGroupController
                  // onSubmitted: (_) => _submitData(),
                  ),
              SizedBox(
                height: 5,
              ),
              TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText:
                        '${LocaleKeys.chain_wordGroupVerification.locale}',
                  ),
                  controller: viewModel.workGroupControllerEqual
                  // onSubmitted: (_) => _submitData(),
                  ),

              Align(
                child: Text('*${LocaleKeys.chain_optional.locale}'),
                alignment: Alignment.topRight,
              ),
              ElevatedButton(
                child: Text('${LocaleKeys.chain_createNewAddress.locale}'),
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(color: Colors.black)),
                onPressed: () {
                  viewModel.onClickNewWalletAddressCreate(context);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextField(
                        decoration: InputDecoration(
                            labelText:
                                '${LocaleKeys.chain_walletAddress.locale}'),
                        controller: viewModel.newwalletAddress,
                        // onSubmitted: (_) =>
                        //     model.submitDataRequestCredi(context),
                        enabled: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 2,
                        // onChanged: (val) {
                        //   titleInput = val;
                        // },
                      )),
                  IconButton(icon: Icon(Icons.copy_outlined), onPressed: () {}),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextField(
                        decoration: InputDecoration(
                            labelText:
                                '${LocaleKeys.common_receiver_pup_key.locale}'),
                        controller: viewModel.newPubkey,
                        // onSubmitted: (_) =>
                        //     model.submitDataRequestCredi(context),
                        enabled: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 2,
                        maxLines: 3,
                        // onChanged: (val) {
                        //   titleInput = val;
                        // },
                      )),
                  IconButton(icon: Icon(Icons.copy_outlined), onPressed: () {}),
                ],
              ),
              OutlinedButton(
                child: Text('${LocaleKeys.chain_copyWalletInfo.locale}'),
                // style: ElevatedButton.styleFrom(
                //     primary: Theme.of(context).primaryColor,
                //     textStyle: TextStyle(color: Colors.black)),
                onPressed: () {
                  viewModel.copiedToClipboardNewWalletInfo(context);
                },
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      );
}
