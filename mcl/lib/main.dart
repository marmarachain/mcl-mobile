import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/models/transaction.dart';
import 'package:mcl/widgets/custom_animation.dart';
import 'package:stacked_services/stacked_services.dart';
import './models/chain.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'core/constants/app/app_constants.dart';
import 'core/init/lang/language_manager.dart';
import 'models/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter('mcl-mobile');

  // Box => sql veritabanlarındaki tablolara denk gelir
  // await Hive.openBox('sunucular');
  Hive.registerAdapter(ChainAdapter());
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox('dashboard');
  await Hive.openBox('kisiler');
  await Hive.openBox('sunucular');
  await Hive.openBox('transactions');

  runApp(EasyLocalization(
      child: MyApp(),
      supportedLocales: LanguageManager.instance.supportedLocales,
      path: ApplicationConstants.LANG_ASSET_PATH));
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: ApplicationConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
        fontFamily: ApplicationConstants.FONT_FAMILY,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      builder: EasyLoading.init(),
    );
  }
}
