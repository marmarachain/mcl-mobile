import 'package:flutter/material.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/ui/mcl_detail/mcl_detail_viewmodel.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletView extends StatelessWidget {
  final String? zincirPassword;

  const WalletView({Key? key, this.zincirPassword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MclDetailViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      builder: (context, viewmodel, child) => CommonPage(
        localeKeys: LocaleKeys.wallet_name,
        backButton: () {
          viewmodel.navigatorHomeScreen();
        },
        appBarFunction: () {},
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: viewmodel.cuzdanAktiflemeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal)),
                            icon: Icon(Icons.lock),
                            labelText:
                                '${LocaleKeys.wallet_amountActivate.tr()}',
                            labelStyle: TextStyle(color: Colors.white24)),
                        focusNode: viewmodel.cuzdanAktiflemeFocusNode,
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).focusColor,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          viewmodel.cuzdanDegerAktifleme();
                        },
                        child: Text('${LocaleKeys.wallet_lock.tr()}'))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: viewmodel.cuzdanDeaktiflemeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal)),
                          labelStyle: TextStyle(color: Colors.white24),
                          icon: Icon(Icons.lock_open),
                          labelText:
                              '${LocaleKeys.wallet_amountDeactivate.tr()}',
                        ),
                        focusNode: viewmodel.cuzdanDeaktiflemeFocusNode,
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).focusColor,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          viewmodel.cuzdanDegerDeaktifleme();
                        },
                        child: Text('${LocaleKeys.wallet_open.tr()}')),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  '${LocaleKeys.wallet_amountInfo.tr()}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                ValueListenableBuilder<Box<dynamic>>(
                    valueListenable: Hive.box('servers').listenable(),
                    builder: (context, mclBlocBox, widget) {
                      var mclBlocChain =
                          Chain(address: '', port: 22, title: '', username: '');
                      if (mclBlocBox.isNotEmpty) {
                        mclBlocChain = mclBlocBox.getAt(
                            viewmodel.secilenBlokZincirIndex.toInt()) as Chain;
                      }
                      return mclBlocChain.marmarainfo == null
                          ? SizedBox()
                          : Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(fontSize: 16),
                                      text: LocaleKeys.stats_normal.tr(),
                                      children: [
                                        TextSpan(
                                            text:
                                                ':     ${mclBlocChain.marmarainfo!['myPubkeyNormalAmount']}')
                                      ]),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                // LocaleText(value: LocaleKeys.stats_activate),
                                RichText(
                                  text: TextSpan(
                                      text: LocaleKeys.stats_activate.tr(),
                                      style: TextStyle(fontSize: 16),
                                      children: [
                                        TextSpan(
                                            text:
                                                ':     ${mclBlocChain.marmarainfo!['myActivatedAmount']}')
                                      ]),
                                ),
                              ],
                            );
                    }),
                SizedBox(
                  height: 40,
                ),
                viewmodel.isBusy
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          viewmodel.myWalletNormalAmountButton(context);
                        },
                        child: Text('${LocaleKeys.common_refresh.tr()}'))
              ],
            ),
          ),
        ),
      ),
      // onModelReady: (viewmodel) =>
      //     viewmodel.onClickCuzdan(this.zincirPassword!),
      viewModelBuilder: () => MclDetailViewModel(),
    );
  }
}

@override
void dispose(MclDetailViewModel model) {
  model.cuzdanAktiflemeFocusNode.dispose();
  model.cuzdanDeaktiflemeFocusNode.dispose();
  // super.dispose();
}
