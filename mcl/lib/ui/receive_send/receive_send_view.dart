import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/ui/receive_send/receive_send_viewmodel.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:mcl/core/extension/context_extension.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/extension/string_extension.dart';

class ReceiveSendView extends StatelessWidget {
  final walletAddress;
  const ReceiveSendView({Key? key, this.walletAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReceiveSendViewModel>.reactive(
      builder: (context, model, child) {
        // if (model.openQrCamera) {
        //   // model.contactsViewOpen();
        // }
        return CommonPage(
          localeKeys: LocaleKeys.receivesend_name,
          appBarFunction: () {},
          backButton: () {
            model.navigatorHomeScreen();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !model.openQrCamera
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        MclText.headingThree(
                            '${LocaleKeys.receivesend_amountSend.locale}'),
                        SizedBox(
                          height: 10,
                        ),
                        MclText.body(
                            '${LocaleKeys.receivesend_receiveAddress.locale}'),
                        Row(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: TextField(
                                  controller: model.addressController,
                                  decoration: InputDecoration(
                                      labelText:
                                          '${LocaleKeys.receivesend_pleaseAddr.locale}',
                                      labelStyle:
                                          TextStyle(color: Colors.white54)),
                                )),
                            IconButton(
                                icon: Icon(Icons.contact_mail_rounded),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          buildBottomSheetContacts(
                                              context, model));
                                }),
                            IconButton(
                                icon: Icon(Icons.qr_code_scanner),
                                onPressed: () {
                                  model.openQrCamera = true;
                                }),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: model.amountController,
                                  focusNode: model.amountFocusNode,
                                  decoration: InputDecoration(
                                      labelText:
                                          '${LocaleKeys.receivesend_amountOfSend.locale}',
                                      labelStyle:
                                          TextStyle(color: Colors.white54)),
                                )),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              model.amountFocusNode.unfocus();
                              model.submitData(context);
                            },
                            child:
                                Text('${LocaleKeys.receivesend_send.locale}')),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          color: Colors.red,
                        ),
                        model.isBusy
                            ? CircularProgressIndicator()
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  MclText.headingThree(
                                      '${LocaleKeys.receivesend_amountReceive.locale}'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  MclText.body(
                                      '${LocaleKeys.receivesend_walletAddress.locale}'),
                                  MclText.body(model.getWalletAddress()),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.copy,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text:
                                                    model.getWalletAddress()));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        '${LocaleKeys.receivesend_copiedToClipboard.locale}')));
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.qr_code_outlined,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (_) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        onLongPress: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: model
                                                                      .getWalletAddress()));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  content: Text(
                                                                      '${LocaleKeys.receivesend_copiedToClipboard.locale}')));
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: QrImageView(
                                                          data: model
                                                              .getWalletAddress(),
                                                          version:
                                                              QrVersions.auto,
                                                          size: 200.0,
                                                          gapless: false,
                                                          embeddedImage: AssetImage(
                                                              'assets/images/logo.png'),
                                                          embeddedImageStyle:
                                                              QrEmbeddedImageStyle(
                                                            size: Size(24, 24),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(model
                                                          .getWalletAddress())
                                                    ],
                                                  );
                                                });
                                          }),
                                    ],
                                  )
                                ],
                              )
                      ],
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
                                          future: model.controller
                                              ?.getFlashStatus(),
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
                                          future:
                                              model.controller?.getCameraInfo(),
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
                                          model.walletAddressSet(
                                              model.result!.code!);
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
        );
      },
      onModelReady: (viewmodel) => viewmodel.onClickCmd(),
      viewModelBuilder: () => ReceiveSendViewModel(),
    );
  }

  Widget buildBottomSheetContacts(
          BuildContext context, ReceiveSendViewModel viewModel) =>
      Padding(
        padding: context.paddingLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${LocaleKeys.common_addressBook.locale}'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${LocaleKeys.common_addressSelect.locale}'),
              ],
            ),
            Container(
                // height: 350,
                child: Expanded(
                    child: ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: Hive.box('contacts').listenable(),
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
                                                backgroundColor: Colors.grey)),
                                        TextSpan(
                                            text: " ${kisi.cuzdanAdresi}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black))
                                      ])),
                                  subtitle: Text(kisi.pubKey),
                                  // trailing: viewModel.selectedContact == index
                                  //     ? Icon(Icons.check)
                                  //     : SizedBox(),
                                  onTap: () {
                                    viewModel.addressController.text =
                                        kisi.cuzdanAdresi;

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
}

@override
void dispose(ReceiveSendViewModel model) {
  model.controller?.dispose();
  // super.dispose();
}
