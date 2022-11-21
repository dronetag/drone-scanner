import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

void showAlertDialog(
  BuildContext context,
  String alertText,
  VoidCallback confirmCallback,
) {
  // set up the buttons
  final Widget cancelButton = TextButton(
    child: const Text('Cancel'),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  final Widget continueButton = TextButton(
    child: const Text('Continue'),
    onPressed: () {
      Navigator.of(context).pop();
      confirmCallback();
    },
  );
  // set up the AlertDialog
  final alert = AlertDialog(
    title: const Text('Confirm Deletion'),
    content: Text(alertText),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (context) {
      return alert;
    },
  );
}

void showSnackBar(
  BuildContext context,
  String snackBarText, {
  Color textColor = Colors.white,
}) {
  final snackBar = SnackBar(
    backgroundColor: AppColors.darkGray.withOpacity(AppColors.toolbarOpacity),
    duration: const Duration(milliseconds: 1500),
    behavior: SnackBarBehavior.floating,
    content: Text(
      snackBarText,
      style: TextStyle(color: textColor),
    ),
    margin: EdgeInsets.only(
      bottom: MediaQuery.of(context).size.height / 10,
      right: Sizes.mapContentMargin,
      left: Sizes.mapContentMargin,
    ),
  );
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
