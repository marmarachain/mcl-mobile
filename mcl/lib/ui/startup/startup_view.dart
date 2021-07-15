import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mcl/core/constants/image_constants.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/ui/startup/startup_viewmodel.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:mcl/core/extension/string_extension.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      onModelReady: (model) =>
          SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        model.startAnimationOnView();
        // model.runStartupLogic();
      }),
      builder: (context, viewModel, child) =>
          buildScaffoldBody(context, viewModel),
      viewModelBuilder: () => StartUpViewModel(),
    );
  }

  Scaffold buildScaffoldBody(BuildContext context, StartUpViewModel viewModel) {
    return Scaffold(
      backgroundColor: Color(0xFF718282),
      body: SafeArea(
          child: Stack(
        children: [
          buildCenterTextWelcome(context, viewModel),
          buildAnimatedAlignIcon(context, viewModel),
        ],
      )),
    );
  }

  Center buildCenterTextWelcome(
      BuildContext context, StartUpViewModel viewModel) {
    return Center(
        child: AnimatedOpacity(
      duration: durationNormal,
      opacity: viewModel.isFirstInit ? 0 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MclText.headline(LocaleKeys.project_splash.locale),
          CircularProgressIndicator.adaptive()
        ],
      ),
    ));
  }

  Widget buildAnimatedAlignIcon(
      BuildContext context, StartUpViewModel viewModel) {
    return AnimatedAlign(
        alignment:
            viewModel.isFirstInit ? Alignment.center : Alignment.bottomCenter,
        duration: durationLow,
        child: Image.asset(ImageConstants.instance.projeIcon));
  }
}
