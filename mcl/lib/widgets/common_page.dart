import 'package:flutter/material.dart';
import 'package:mcl/core/components/text/locale_text.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';

class CommonPage extends StatelessWidget {
  final Widget? child;
  final String? localeKeys;
  final Function? appBarFunction;
  final List<Widget>? appBarWidget;
  final PreferredSizeWidget? bottom;
  final VoidCallback? backButton;
  const CommonPage(
      {Key? key,
      this.child,
      this.localeKeys,
      this.appBarFunction,
      this.appBarWidget,
      this.bottom,
      this.backButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5F627D),
              Color(0xFF313347),
            ],
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Transform.translate(
              offset: Offset(-15, 0),
              child: localeKeys != LocaleKeys.project_name
                  ? new IconButton(
                      icon: new Icon(Icons.arrow_back, color: Colors.orange),
                      onPressed: () => backButton!(),
                    )
                  : SizedBox(),
            ),
            titleSpacing: localeKeys != LocaleKeys.project_name ? 0 : -30,
            title: LocaleText(value: localeKeys!),
            actions: appBarWidget,
            bottom: bottom,
          ),
          backgroundColor: Colors.transparent,
          body: this.child,
        ));
  }
}
