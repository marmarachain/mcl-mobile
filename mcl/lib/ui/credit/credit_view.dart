import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mcl/core/components/slider/range_price_slider.dart';
import 'package:mcl/core/components/text/locale_text.dart';
import 'package:mcl/core/constants/enums/mcl_loop_enum.dart';
import 'package:mcl/core/extension/context_extension.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/ui/mcl_detail/mcl_detail_viewmodel.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/extension/string_extension.dart';

// import 'credit_wallet_view.dart';

class CreditView extends StatelessWidget {
  final String? zincirPassword;
  const CreditView({Key? key, this.zincirPassword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MclDetailViewModel>.reactive(
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5F627D),
              Color(0xFF313347),
            ],
          ),
        ),
        child: !model.openQrCamera
            ? DefaultTabController(
                length: 4,
                initialIndex: model.tabIndex,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: new IconButton(
                      icon: new Icon(Icons.arrow_back, color: Colors.orange),
                      onPressed: () => model.navigatorHomeScreen(),
                    ),
                    title: Text(LocaleKeys.credit_name.tr()),
                    bottom: TabBar(
                        isScrollable: true,
                        unselectedLabelColor: Colors.redAccent,
                        indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                        // indicator: ShapeDecoration(
                        //     color: Colors.redAccent,
                        //     shape: BeveledRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //         side: BorderSide(
                        //           color: Colors.redAccent,
                        //         ))),
                        onTap: (index) {
                          model.tabIndex = index;
                        },
                        tabs: [
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(LocaleKeys.credit_issuer_name.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(LocaleKeys.credit_holder_name.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(LocaleKeys.credit_endorser_name.tr()),
                            ),
                          ),
                          // Tab(
                          //   child: Align(
                          //     alignment: Alignment.center,
                          //     child: Text("Döngü Bilgisi"),
                          //   ),
                          // ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  LocaleKeys.credit_active_loops_name.tr()),
                            ),
                          ),
                        ]),
                    actions: <Widget>[
                      // IconButton(
                      //   icon: Icon(Icons.scanner),
                      //   onPressed: () {
                      //     model.denemeModel();
                      //   },
                      // ),
                      (!model.switchStateEndorser && model.tabIndex == 2) ||
                              model.tabIndex == 3
                          ? IconButton(
                              icon: Icon(Icons.upload_rounded),
                              onPressed: () {
                                model.createExcel();
                              },
                            )
                          : SizedBox(),
                      !model.switchStateEndorser && model.tabIndex == 2
                          ? IconButton(
                              icon: Icon(Icons.filter_alt),
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        buildBottomSheetBody(context, model));
                              },
                            )
                          : SizedBox(),
                      // !model.switchStateEndorser
                      //     ? IconButton(
                      //         icon: Icon(Icons.search),
                      //         onPressed: () {
                      //           print('KREDI +++');
                      //           model.startCirantaSearch(context);
                      //         },
                      //       )
                      //     : SizedBox(),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          // print('KREDI +++');
                          model.creditCustomRefresh(context);
                        },
                      ),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                  body: model.isBusy
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : TabBarView(children: [
                          tabIssuer(model, context),
                          tabBearer(model, context),
                          tabEndorser(model, context),
                          // Center(
                          //   child: Text('Döngü Bilgisi'),
                          // ),
                          tabActiveLoops(model),
                          // MclKrediAktifView(zincirPassword: this.zincirPassword)
                        ]),
                ),
              )
            : Column(
                children: <Widget>[
                  Expanded(flex: 4, child: model.buildQrView(context)),
                  Expanded(
                    flex: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (model.result != null)
                            // Text(
                            //     'Barcode Type: ${describeEnum(model.result!.format)}   Data: ${model.result!.code}')
                            MclText.body(
                                '${LocaleKeys.receivesend_receiveAddress.locale}: ${model.result!.code}')
                          else
                            MclText.body(
                                '${LocaleKeys.receivesend_scanQrCode.locale}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await model.controller?.toggleFlash();
                                      // setState(() {});
                                    },
                                    child: FutureBuilder(
                                      future:
                                          model.controller?.getFlashStatus(),
                                      builder: (context, snapshot) {
                                        // Text(
                                        //     'Flash: ${snapshot.data}');
                                        return Text('Flash');
                                      },
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await model.controller?.flipCamera();
                                      // setState(() {});
                                    },
                                    child: FutureBuilder(
                                      future: model.controller?.getCameraInfo(),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          // Text(
                                          //     'Camera facing ${describeEnum(snapshot.data!)}');
                                          return Text(
                                              '${LocaleKeys.receivesend_cameraChange.locale}');
                                        } else {
                                          // Text('loading');
                                          return Text(
                                              '${LocaleKeys.receivesend_cameraChange.locale}');
                                        }
                                      },
                                    )),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await model.controller?.pauseCamera();
                                  },
                                  child: Text(
                                      '${LocaleKeys.receivesend_cameraPause.locale}',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await model.controller?.resumeCamera();
                                  },
                                  child: Text(
                                      '${LocaleKeys.receivesend_cameraResume.locale}',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (model.result != null) {
                                      model
                                          .walletAddressSet(model.result!.code);
                                    }

                                    model.openQrCamera = false;
                                  },
                                  child: Text(
                                      '${LocaleKeys.common_approve.locale}',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
      viewModelBuilder: () => MclDetailViewModel(),
    );
  }

  Widget buildBottomSheetBody(
          BuildContext context, MclDetailViewModel viewModel) =>
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
                  child: RangePriceSLider(
                    min: 500,
                    max: 5000,
                    onCompleted: (values) {
                      viewModel.changeRangeValues(values);
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      viewModel.fetchMinMax();
                    },
                    icon: Icon(Icons.check_box_outline_blank))
              ],
            ),
            Card(
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    children: MclLoopSortValues.values
                        .map((e) => IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              viewModel.fetchSort(e);
                            },
                            icon: Text(e.rawValue, maxLines: 1)))
                        .toList(),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => viewModel.changeAscending(true),
                          icon: Icon(Icons.north)),
                      IconButton(
                          onPressed: () => viewModel.changeAscending(false),
                          icon: Icon(Icons.south)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  SingleChildScrollView tabEndorser(
      MclDetailViewModel model, BuildContext ctx) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Align(
          //   alignment: Alignment.topLeft,
          //   child: Text(
          //     'Cüzdanlarım',
          //     textAlign: TextAlign.left,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(),
                model.switchStateEndorser
                    ? LocaleText(
                        value:
                            LocaleKeys.credit_endorser_endorsement_request_list)
                    : LocaleText(
                        value: LocaleKeys.credit_endorser_bearer_loops),
                Switch(
                    value: model.switchStateEndorser,
                    onChanged: (bool deger) {
                      model.switchStateEndorser = deger;
                    })
              ],
            ),
          ),
          // IconButton(
          //     icon: Icon(Icons.ac_unit),
          //     onPressed: () async {
          //       // model.createExcel();
          //       model.acayipNedir();
          //       model.setBusy(true);
          //       await Future.delayed(Duration(seconds: 4));
          //       model.setBusy(false);
          //     }),

          // Text(
          //   'Hamil Döngüleri ${model.krediCirantaTotalAmount}',
          //   style: TextStyle(color: Colors.white),
          // ),
          !model.switchStateEndorser
              ? ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) async {
                    print(isExpanded);
                    model.cirantoIsExpande(index, !isExpanded);
                    if (isExpanded == false &&
                        model.cirantaLoop[index].body == '') {
                      print(model.cirantaLoop[index].header);

                      var gelen = await model.onClickCirantaDonguDetay(
                          model.cirantaLoop[index].header!);
                      print(gelen);
                    }
                  },
                  children: model.cirantaLoop.map((CirantaLoop item) {
                    return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${item.id}- ${item.amount}\n${DateFormat('dd.MM.yyyy HH:mm').format(item.matures!)}\n${item.sendPerson!.length > 25 ? item.sendPerson!.substring(0, 25) : item.sendPerson}"),
                                  Spacer(),
                                  item.sendPerson == ''
                                      ? IconButton(
                                          icon: Icon(Icons.person_search_sharp),
                                          onPressed: () {
                                            model.panoyaKopyalandi(context,
                                                item.sendPubKey!, 'PubKey');
                                          })
                                      : SizedBox(),
                                  IconButton(
                                      icon: Icon(Icons.copy_outlined),
                                      onPressed: () {
                                        model.panoyaKopyalandi(
                                            context, item.header!, 'Baton id');
                                      })
                                ],
                              ),
                            ),
                          );
                        },
                        isExpanded: item.isExpanded,
                        body: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: item.body! == ''
                                  ? CircularProgressIndicator()
                                  : Text(item.header!)),
                        ));
                  }).toList(),
                )
              : model.endorsementRequestList.length == 0
                  ? Center(
                      child: MclText.body(
                        '${LocaleKeys.credit_endorserRequestNo.tr()}',
                        color: kcPrimaryColor,
                      ),
                    )
                  : ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) async {
                        print(isExpanded);
                        model.issuerIsExpanded(index, !isExpanded);
                        if (isExpanded == false &&
                            model.endorsementRequestList[index].txid == '') {
                          print(
                              model.endorsementRequestList[index].creationtxid);

                          // var gelen = await model.onClickCirantaDonguDetay(
                          //     this.zincirPassword!, model.endorsementRequestList[index].id!);
                          // print(gelen);
                        }
                      },
                      children:
                          model.endorsementRequestList.map((IssuerLoop item) {
                        return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${item.id} ${item.txid!.substring(0, 20)} \n${item.amount} ${item.matures}"),
                                      IconButton(
                                        icon: Icon(Icons.remove_red_eye),
                                        onPressed: () {
                                          model.issuerCreditConfirmationDialog(
                                              "TXID: ${item.txid!} \nAMOUNT: ${item.amount}\nMATURES: ${item.matures}\nRECEIVER PUBKEY: ${item.receivepk} \n",
                                              item.receivepk!,
                                              item.txid!,
                                              ctx);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            isExpanded: item.isExpanded,
                            body: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  child: item.txid! == ''
                                      ? CircularProgressIndicator()
                                      : Text(item.txid!)),
                            ));
                      }).toList(),
                    )
        ],
      ),
    );
  }

  Widget tabIssuer(MclDetailViewModel model, BuildContext ctx) {
    return model.issuerLoop.length == 0
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: model.isBusy
                ? CircularProgressIndicator()
                : MclText.body('${LocaleKeys.credit_description.tr()}'),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                ),
                // IconButton(
                //     icon: Icon(Icons.ac_unit),
                //     onPressed: () async {
                //       model.onClickIssuerRefresh(0);
                //     }),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${LocaleKeys.credit_description2.tr()}',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) async {
                    print(isExpanded);
                    model.issuerIsExpanded(index, !isExpanded);
                    if (isExpanded == false &&
                        model.issuerLoop[index].txid == '') {
                      print(model.issuerLoop[index].creationtxid);

                      // var gelen = await model.onClickCirantaDonguDetay(
                      //     this.zincirPassword!, model.issuerLoop[index].id!);
                      // print(gelen);
                    }
                  },
                  children: model.issuerLoop.map((IssuerLoop item) {
                    return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${item.id} ${item.txid!.substring(0, 20)} \n${item.amount} ${item.matures}"),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      var kisiIndeksi = model
                                          .adresDefteriListesi
                                          .indexWhere((element) =>
                                              element.pubKey == item.receivepk);
                                      var rehberKaydi = '';
                                      if (kisiIndeksi != -1) {
                                        rehberKaydi =
                                            "(${model.adresDefteriListesi[kisiIndeksi].isim})";
                                      }
                                      model.issuerCreditConfirmationDialog(
                                          "TXID: ${item.txid!} \nAMOUNT: ${item.amount}\nMATURES: ${item.matures}\nRECEIVER PUBKEY: ${item.receivepk} $rehberKaydi\n",
                                          item.receivepk!,
                                          item.txid!,
                                          ctx);
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        isExpanded: item.isExpanded,
                        body: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: item.txid! == ''
                                  ? CircularProgressIndicator()
                                  : Text(item.txid!)),
                        ));
                  }).toList(),
                )
              ],
            ),
          );
  }

  SingleChildScrollView tabActiveLoops(MclDetailViewModel model) {
    return SingleChildScrollView(
      child: model.isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: Text(
                  //     'Cüzdanlarım',
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),

                  ExpansionPanelList.radio(
                    initialOpenPanelValue: 1,
                    children: model.dataLoop
                        .map<ExpansionPanelRadio>((ItemLoop item) {
                      return ExpansionPanelRadio(
                          value: item.id,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.id.toString()),
                                  Spacer(),
                                  Text(item.myAmountLockedInLoopValue),
                                  // Row(
                                  //   children: [
                                  //     IconButton(
                                  //         icon: Icon(Icons.copy),
                                  //         onPressed: () {}),
                                  //     IconButton(
                                  //         icon: Icon(Icons.copy),
                                  //         onPressed: () {})
                                  //   ],
                                  // )
                                ],
                              ),
                            );
                          },
                          body: ListTile(
                              title: Text(item.loopAddressValue),
                              subtitle: Text(item.txBatonValue),
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
                ],
              ),
            ),
    );
  }

  Widget buildBottomSheetContacts(
          BuildContext context, MclDetailViewModel viewModel) =>
      Padding(
        padding: context.paddingLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${LocaleKeys.common_addressBook.tr()}'),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: viewModel.contactsViewOpen),
                IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            ),
            Divider(height: 2, thickness: 2),
            Container(
                // height: 350,
                child: Expanded(
                    child: ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: Hive.box('kisiler').listenable(),
                        builder: (context, kisilerBox, widget) {
                          return ListView.builder(
                              itemCount: kisilerBox.length,
                              itemBuilder: (ctx, index) {
                                final kisi = kisilerBox.getAt(index) as Person;
                                return ListTile(
                                  title: RichText(
                                      text: TextSpan(
                                          text: "${kisi.isim}  ",
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                        TextSpan(
                                            text: 'MCL',
                                            style: TextStyle(
                                                color: Colors.red,
                                                backgroundColor: Colors.grey))
                                      ])),
                                  subtitle: Text(kisi.pubKey),
                                  // trailing: viewModel.selectedContact == index
                                  //     ? Icon(Icons.check)
                                  //     : SizedBox(),
                                  onTap: () {
                                    print(index);
                                    viewModel.selectedContact = index;
                                    viewModel.bearerPubKeyController.text =
                                        kisi.pubKey;
                                    viewModel.bearerName = kisi.isim;
                                    // notifyListeners();
                                    Navigator.of(context).pop();
                                    // openContactBook(ctx);
                                    // buildBottomSheetContacts(context, viewModel);
                                  },
                                );
                              });
                        }))),
          ],
        ),
      );

  SingleChildScrollView tabBearer(
      MclDetailViewModel model, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(),
                !model.switchState
                    ? LocaleText(
                        value: LocaleKeys.credit_holder_first_credit_request)
                    : LocaleText(
                        value: LocaleKeys.credit_holder_endorsement_request),
                Switch(
                    value: model.switchState,
                    onChanged: (bool deger) {
                      model.switchState = deger;
                    })
              ],
            ),
            Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: TextField(
                              decoration: InputDecoration(
                                  labelText: model.bearerName != ''
                                      ? model.bearerName
                                      : '${LocaleKeys.common_receiver_pup_key.tr()}'),
                              controller: model.bearerPubKeyController,
                              onSubmitted: (_) =>
                                  model.submitDataRequestCredi(context),
                              keyboardType: TextInputType.multiline,
                              minLines: 2,
                              maxLines: 3,
                              // onChanged: (val) {
                              //   titleInput = val;
                              // },
                            )),
                        IconButton(
                            icon: Icon(Icons.contact_mail_rounded),
                            onPressed: () {
                              // model.openContactBook(context);
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      buildBottomSheetContacts(context, model));
                            }),
                        IconButton(
                            icon: Icon(Icons.qr_code_scanner),
                            onPressed: () {
                              model.openQrCamera = true;
                            }),
                      ],
                    ),
                    TextField(
                        decoration: InputDecoration(
                            labelText: !model.switchState
                                ? '${LocaleKeys.common_amount.tr()}'
                                : 'Baton Txid'),
                        controller: model.bearerAmountOrBatonController,
                        keyboardType: !model.switchState
                            ? TextInputType.number
                            : TextInputType.text,
                        focusNode: model.bearerAmountOrBatonFocusNode,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          model.submitDataRequestCredi(context);
                        }
                        // onChanged: (val) => amountInput = val,
                        ),
                    !model.switchState
                        ? Container(
                            height: 70,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    model.selectedDate == null
                                        ? '${LocaleKeys.credit_dateNoSelect.tr()}'
                                        : '${LocaleKeys.credit_SelectedDate.tr()}: ${DateFormat(('dd.MM.yyyy')).format(model.selectedDate!)}',
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: kcButtonLightColor),
                                  child: Text(
                                    '${LocaleKeys.credit_SelectDate.tr()}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  onPressed: () {
                                    model.presentDatePickerBearer(context);
                                  },
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Text('${LocaleKeys.common_request_credit.tr()}'),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            textStyle: TextStyle(color: Colors.black)),
                        onPressed: () {
                          model.submitDataRequestCredi(context);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

@override
void dispose(MclDetailViewModel model) {
  model.controller?.dispose();
  model.bearerAmountOrBatonFocusNode.dispose();
  // super.dispose();
}
