import 'package:mcl_ui/mcl_ui.dart';
import 'package:flutter/material.dart';

class ExampleView extends StatelessWidget {
  const ExampleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        children: [
          MclText.headingOne('Design System'),
          verticalSpaceSmall,
          Divider(),
          verticalSpaceSmall,
          ...buttonWidgets,
          ...textWidgets,
          ...inputFields,
        ],
      ),
    );
  }

  List<Widget> get textWidgets => [
        MclText.headline('Text Styles'),
        verticalSpaceMedium,
        MclText.headingOne('Heading One'),
        verticalSpaceMedium,
        MclText.headingTwo('Heading Two'),
        verticalSpaceMedium,
        MclText.headingThree('Heading Three'),
        verticalSpaceMedium,
        MclText.headline('Headline'),
        verticalSpaceMedium,
        MclText.subheading('This will be a sub heading to the headling'),
        verticalSpaceMedium,
        MclText.body('Body Text that will be used for the general body'),
        verticalSpaceMedium,
        MclText.caption('This will be the caption usually for smaller details'),
        verticalSpaceMedium,
      ];

  List<Widget> get buttonWidgets => [
        MclText.headline('Buttons'),
        verticalSpaceMedium,
        MclText.body('Normal'),
        verticalSpaceSmall,
        MclButton(
          title: 'SIGN IN',
        ),
        verticalSpaceSmall,
        MclText.body('Disabled'),
        verticalSpaceSmall,
        MclButton(
          title: 'SIGN IN',
          disabled: true,
        ),
        verticalSpaceSmall,
        MclText.body('Busy'),
        verticalSpaceSmall,
        MclButton(
          title: 'SIGN IN',
          busy: true,
        ),
        verticalSpaceSmall,
        MclText.body('Outline'),
        verticalSpaceSmall,
        MclButton.outline(
          title: 'Select location',
          leading: Icon(
            Icons.send,
            color: kcPrimaryColor,
          ),
        ),
        verticalSpaceMedium,
      ];

  List<Widget> get inputFields => [
        MclText.headline('Input Field'),
        verticalSpaceSmall,
        MclText.body('Normal'),
        verticalSpaceSmall,
        MclInputField(
          controller: TextEditingController(),
          placeholder: 'Enter Password',
        ),
        verticalSpaceSmall,
        MclText.body('Leading Icon'),
        verticalSpaceSmall,
        MclInputField(
          controller: TextEditingController(),
          leading: Icon(Icons.reset_tv),
          placeholder: 'Enter TV Code',
        ),
        verticalSpaceSmall,
        MclText.body('Trailing Icon'),
        verticalSpaceSmall,
        MclInputField(
          controller: TextEditingController(),
          trailing: Icon(Icons.clear_outlined),
          placeholder: 'Search for things',
        ),
      ];
}
