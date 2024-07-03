import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import 'proximity_alert_snackbar.dart';

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

Future<bool> showLocationPermissionDialog({
  required BuildContext context,
  required bool showWhileUsingPermissionExplanation,
}) async {
  // set up the buttons
  final actions = _getPermissionDialogActions(context);
  // set up the AlertDialog
  final alert = AlertDialog(
    title: const Text('Location permission required'),
    content: Text.rich(
      TextSpan(
        text: 'Drone Scanner requires a location permission to scan for '
            'Bluetooth devices.\n\n',
        children: [
          if (showWhileUsingPermissionExplanation) ...[
            const TextSpan(text: 'Please choose\nthe '),
            const TextSpan(
              text: '"While using the app"\n',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text:
                  'option to enable scans while the app is in foreground.\n\n',
            ),
          ],
          const TextSpan(
              text: 'If you already denied the permission request,'
                  ' please go to\nthe '),
          const TextSpan(
            text: '"App settings"\n',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: 'and enable location manually.'),
        ],
      ),
    ),
    actions: actions.values.toList(),
  );
  // show the dialog
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return alert;
    },
  );
  return result ?? false;
}

Future<bool> showBackgroundPermissionDialog({
  required BuildContext context,
}) async {
  // set up the buttons
  final actions = _getPermissionDialogActions(context);
  final isAndroid = Platform.isAndroid;
  // set up the AlertDialog
  final alert = AlertDialog(
    title: const Text('Background location permission'),
    content: const Text.rich(
      TextSpan(
        text: 'Drone Scanner requires background location permission to scan '
            'for nearby aircraft while in the background.\n\n',
        children: [
          TextSpan(
              text: 'If you wish to use the Drone Radar feature or gather data '
                  'while the app is minimized, please select\nthe '),
          TextSpan(
            text: '"Allow all the time"\n',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: 'option in application settings.\n\n',
          ),
        ],
      ),
    ),
    actions: [
      actions['cancel']!,
      if (isAndroid) actions['continue']!,
      if (!isAndroid) actions['appSettings']!,
    ],
  );
  // show the dialog
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return alert;
    },
  );
  return result ?? false;
}

Map<String, Widget> _getPermissionDialogActions(BuildContext context) {
  return {
    'cancel': TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context, false);
      },
    ),
    'appSettings': TextButton(
      child: const Text('App settings'),
      onPressed: () {
        Navigator.pop(context, true);
        AppSettings.openAppSettings();
      },
    ),
    'continue': TextButton(
      child: const Text('Continue'),
      onPressed: () {
        Navigator.pop(context, true);
      },
    ),
  };
}

void showSnackBar(
  BuildContext context,
  String snackBarText, {
  Color textColor = Colors.white,
  int durationMs = 1500,
}) {
  final snackBar = SnackBar(
    backgroundColor: AppColors.darkGray.withOpacity(AppColors.toolbarOpacity),
    duration: Duration(milliseconds: durationMs),
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

Flushbar createProximityAlertFlushBar(BuildContext context, int durationSec) {
  return Flushbar(
    duration: Duration(seconds: durationSec),
    backgroundColor: Colors.transparent,
    flushbarPosition: FlushbarPosition.TOP,
    padding: const EdgeInsets.symmetric(
      horizontal: Sizes.mapContentMargin,
      vertical: Sizes.standard,
    ),
    messageText: ProximityAlertSnackbar(
      expirationTime: durationSec,
    ),
  );
}
