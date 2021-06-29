import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  // final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  Future<void> runStartupLogic() async {
    _navigationService.replaceWith(Routes.homeView);
  }
}
