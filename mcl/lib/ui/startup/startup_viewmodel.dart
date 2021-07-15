import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  // final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  bool isFirstInit = true;

  Future<void> runStartupLogic() async {
    _navigationService.replaceWith(Routes.homeView);
  }

  Future<void> _changeFirstInit() async {
    isFirstInit = !isFirstInit;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2));
    runStartupLogic();
  }

  Future<void> startAnimationOnView() async {
    // if (context == null) return;
    await Future.delayed(durationLow);
    _changeFirstInit();
  }
}
