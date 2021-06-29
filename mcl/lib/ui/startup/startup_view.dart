import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mcl/ui/startup/startup_viewmodel.dart';
import 'package:stacked/stacked.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      onModelReady: (model) =>
          SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Color(0xFF718282),
        body: Center(
          child: Image.asset('assets/images/mcl_logo_large.png'),
        ),
      ),
      viewModelBuilder: () => StartUpViewModel(),
    );
  }
}
