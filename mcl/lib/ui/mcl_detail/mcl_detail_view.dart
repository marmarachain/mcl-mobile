import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mcl/core/components/bottom_navy_bar.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/ui/chain/chain_view.dart';
import 'package:mcl/ui/credit/credit_view.dart';
import 'package:mcl/ui/receive_send/receive_send_view.dart';
import 'package:mcl/ui/transactions/transactions_view.dart';
import 'package:mcl/ui/wallet/wallet_view.dart';
import 'package:stacked/stacked.dart';
import './mcl_detail_trackmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class MclDetailView extends StatelessWidget {
  final String? passwordServer;

  MclDetailView({Key? key, this.passwordServer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MclDetailTrackModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: model.reverse,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
                child: child,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal);
          },
          child: getViewForIndex(model.currentIndex),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: model.currentIndex,
          showElevation: true,
          onItemSelected: model.setIndex,
          items: [
            // BottomNavyBarItem(
            //   icon: Icon(Icons.home_outlined),
            //   title: Text('Dashboard'),
            //   activeColor: Colors.red,
            // ),
            BottomNavyBarItem(
              icon: Icon(Icons.all_inclusive_outlined),
              title: Text('${LocaleKeys.chain_name.tr()}'),
              activeColor: Colors.red,
            ),
            BottomNavyBarItem(
                icon: Icon(Icons.account_balance_wallet),
                title: Text('${LocaleKeys.wallet_name.tr()}'),
                activeColor: Colors.purpleAccent),
            BottomNavyBarItem(
                icon: Icon(Icons.swap_vert),
                title: Text('${LocaleKeys.receivesend_name.tr()}'),
                activeColor: Colors.purpleAccent),
            BottomNavyBarItem(
                icon: Icon(Icons.credit_card),
                title: Text('${LocaleKeys.credit_name.tr()}'),
                activeColor: Colors.pink),
            BottomNavyBarItem(
                icon: Icon(Icons.list),
                title: Text('İşlemler'),
                activeColor: Colors.blue),
          ],
        ),
      ),
      viewModelBuilder: () => MclDetailTrackModel(),
    );
  }

  Widget getViewForIndex(int index) {
    switch (index) {
      // case 0:
      //   // return PostsView();
      //   return BootstrapView();
      case 0:
        // return PostsView();
        return ChainView();
      case 1:
        return WalletView(
          zincirPassword: this.passwordServer,
        );
      case 2:
        return ReceiveSendView();
      case 3:
        return CreditView();
      default:
        return TransactionsView();
    }
  }
}
