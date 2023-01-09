import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/sizes.dart';
import '../../app/custom_about_dialog.dart';
import '../../app/dialogs.dart';
import '../../help/help_page.dart';
import '../../preferences/preferences_page.dart';
import 'custom_popup_menu_divider.dart';

enum ToolbarMenuAction {
  toggleBT,
  toggleWifi,
  openSettings,
  openHelp,
  openAbout,
}

void setWifiUsed(BuildContext context, Function setState,
    {required bool used}) {
  final standardsCubitState = context.read<StandardsCubit>().state;
  if (used &&
      !standardsCubitState.locationEnabled &&
      standardsCubitState.androidSystem) {
    final snackBarText = 'Location has to be enabled for Wi-Fi scanning. '
        'Please enable location in phone settings.';
    showWifiSnackBar(context, errorText: snackBarText);
  } else {
    context
        .read<OpendroneIdCubit>()
        .setWifiUsed(wifiUsed: used)
        .then((value) => setState);
    showWifiSnackBar(context, started: used);
  }
}

void setBTUsed(BuildContext context, Function setState, {required bool used}) {
  final standardsCubitState = context.read<StandardsCubit>().state;
  if (used &&
      !standardsCubitState.locationEnabled &&
      standardsCubitState.androidSystem) {
    final snackBarText = 'Location has to be enabled for Bluetooth scanning. '
        'Please enable location in phone settings.';
    showBtSnackBar(context, errorText: snackBarText);
  } else {
    context
        .read<OpendroneIdCubit>()
        .setBtUsed(btUsed: used)
        .then((value) => setState);
    showBtSnackBar(context, started: used);
  }
}

void showWifiSnackBar(BuildContext context,
    {bool? started, String? errorText}) {
  late final String snackBarText;
  if (started != null) {
    if (started) {
      snackBarText = 'Wi-Fi Scanning Started.';
    } else {
      snackBarText = 'Wi-Fi Scanning Stopped.';
    }
    showSnackBar(context, snackBarText);
  } else if (errorText != null) {
    showSnackBar(context, errorText);
  }
}

void showBtSnackBar(BuildContext context, {bool? started, String? errorText}) {
  late final String snackBarText;
  if (started != null) {
    if (started) {
      snackBarText = 'Bluetooth Scanning Started.';
    } else {
      snackBarText = 'Bluetooth Scanning Stopped.';
    }
    showSnackBar(context, snackBarText);
  } else if (errorText != null) {
    showSnackBar(context, errorText);
  }
}

Future<ToolbarMenuAction?> displayToolbarMenu(BuildContext context) async {
  final labelStyle = TextStyle(
    fontSize: 16,
  );
  return showMenu<ToolbarMenuAction>(
    constraints: BoxConstraints(),
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    items: [
      PopupMenuItem(
        value: ToolbarMenuAction.toggleBT,
        padding: EdgeInsets.symmetric(horizontal: Sizes.mapContentMargin),
        child: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value:
                    context.watch<OpendroneIdCubit>().state.isScanningBluetooth,
                visualDensity: VisualDensity.compact,
                onChanged: (value) {
                  setBTUsed(context, setState, used: value!);
                },
              ),
              GestureDetector(
                onTap: () {
                  final value = context
                      .read<OpendroneIdCubit>()
                      .state
                      .isScanningBluetooth;
                  setBTUsed(context, setState, used: !value);
                },
                child: Text(
                  'Enable Bluetooth',
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      if (context.read<StandardsCubit>().state.androidSystem)
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: Sizes.mapContentMargin),
          value: ToolbarMenuAction.toggleWifi,
          child: StatefulBuilder(
            builder: (context, setState) => Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: context.watch<OpendroneIdCubit>().state.isScanningWifi,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) {
                    setWifiUsed(context, setState, used: value!);
                  },
                ),
                GestureDetector(
                  onTap: (() {
                    final value =
                        context.read<OpendroneIdCubit>().state.isScanningWifi;
                    setWifiUsed(context, setState, used: !value);
                  }),
                  child: Text(
                    'Enable Wi-Fi',
                    style: labelStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      const CustomPopupMenuDivider(),
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: ToolbarMenuAction.openSettings,
        child: Text(
          'Preferences',
          style: labelStyle,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: ToolbarMenuAction.openHelp,
        child: Text(
          'Help',
          style: labelStyle,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: ToolbarMenuAction.openAbout,
        child: Text(
          'About',
          style: labelStyle,
        ),
      ),
    ],
    position: RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height / 8,
      Sizes.screenSpacing,
      Sizes.screenSpacing,
    ),
  );
}

void handleAction(BuildContext context, ToolbarMenuAction action) {
  switch (action) {
    case ToolbarMenuAction.openSettings:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PreferencesPage(),
          settings: RouteSettings(
            name: PreferencesPage.routeName,
          ),
        ),
      );
      break;
    case ToolbarMenuAction.openHelp:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HelpPage(),
          settings: RouteSettings(
            name: HelpPage.routeName,
          ),
        ),
      );
      break;
    case ToolbarMenuAction.openAbout:
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAboutDialog();
        },
      );
      break;
    default:
  }
}
