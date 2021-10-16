import 'package:flutter/widgets.dart';
import 'package:mcl/app/app.locator.dart';
import 'package:mcl/app/app.logger.dart';
import 'package:mcl/app/app.router.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:new_version/new_version.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  // final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  final newVersion = NewVersion(
    // iOSId: 'com.google.Vespa',
    androidId: 'com.mcl.mobile.mcl',
  );

  bool isFirstInit = true;

  advancedStatusCheck(NewVersion newVersion, BuildContext context) async {
    final status = await newVersion.getVersionStatus();
    print(status!.releaseNotes);
    print(status.appStoreLink);
    print(status.localVersion);
    print(status.storeVersion);
    print(status.canUpdate.toString());
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,
      dialogTitle: 'Custom Title',
      dialogText: 'Custom Text',
    );
  }

  Future<void> runStartupLogic() async {
    _navigationService.replaceWith(Routes.homeView);
  }

  Future<void> _changeFirstInit() async {
    isFirstInit = !isFirstInit;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2));
    runStartupLogic();
  }

  Future<void> startAnimationOnView(context) async {
    // if (context == null) return;
    await Future.delayed(durationLow);
    advancedStatusCheck(newVersion, context);
    _changeFirstInit();
  }
}
