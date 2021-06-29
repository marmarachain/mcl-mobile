import 'package:mcl_ui/src/shared/app_colors.dart';
import 'package:mcl_ui/src/shared/styles.dart';
import 'package:flutter/material.dart';

class MclText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const MclText.headingOne(this.text) : style = heading1Style;
  const MclText.headingTwo(this.text) : style = heading2Style;
  const MclText.headingThree(this.text) : style = heading3Style;
  const MclText.headline(this.text) : style = headlineStyle;
  const MclText.subheading(this.text) : style = subheadingStyle;
  const MclText.caption(this.text) : style = captionStyle;

  MclText.body(this.text, {Color color = kcMediumGreyColor})
      : style = bodyStyle.copyWith(color: color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }
}
