import 'package:mcl/services/ssh_service.dart';
import 'package:mcl/ui/contact/contact_view.dart';
import 'package:mcl/ui/home/home_view.dart';
import 'package:mcl/ui/mcl_detail/mcl_detail_view.dart';
import 'package:mcl/ui/startup/startup_view.dart';
import 'package:mcl/ui/transactions/transactions_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(routes: [
  MaterialRoute(page: StartUpView, initial: true),
  MaterialRoute(page: HomeView),
  MaterialRoute(page: ContactView),
  MaterialRoute(page: MclDetailView),
  MaterialRoute(page: TransactionsView),
  // MaterialRoute(page: ChainView),
  // MaterialRoute(page: WalletView),
  // MaterialRoute(page: ReceiveSendView),
], dependencies: [
  LazySingleton(classType: NavigationService),
  LazySingleton(classType: DialogService),
  LazySingleton(classType: BottomSheetService),
  LazySingleton(classType: SshService),
], logger: StackedLogger())
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
