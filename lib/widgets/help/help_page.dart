import 'package:flutter/material.dart';

import '../../constants/sizes.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ColoredBox(
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top,
            left: Sizes.preferencesMargin,
            right: Sizes.preferencesMargin,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
