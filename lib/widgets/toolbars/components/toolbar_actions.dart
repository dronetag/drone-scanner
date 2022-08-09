import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/sizes.dart';
import '../../app/custom_about_dialog.dart';
import '../../app/dialogs.dart';
import '../../preferences/preferences_page.dart';

enum ToolbarMenuAction {
  toggleBT,
  toggleWifi,
  openSettings,
  openAbout,
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
                  context
                      .read<OpendroneIdCubit>()
                      .setBtUsed(btUsed: value!)
                      .then((value) => setState);
                  late final String snackBarText;
                  if (value) {
                    snackBarText = 'Bluetooth Scanning Started.';
                  } else {
                    snackBarText = 'Bluetooth Scanning Stopped.';
                  }
                  showSnackBar(context, snackBarText);
                },
              ),
              Text(
                'Enable Bluetooth',
                style: labelStyle,
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
                    context
                        .read<OpendroneIdCubit>()
                        .setWifiUsed(wifiUsed: value!)
                        .then(
                          (value) => setState(
                            () {},
                          ),
                        );
                    late final String snackBarText;
                    if (value) {
                      snackBarText = 'Wi-Fi Scanning Started.';
                    } else {
                      snackBarText = 'Wi-Fi Scanning Stopped.';
                    }
                    showSnackBar(context, snackBarText);
                  },
                ),
                Text(
                  'Enable Wi-Fi',
                  style: labelStyle,
                ),
              ],
            ),
          ),
        ),
      const PopupMenuDivider(),
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
        MaterialPageRoute(builder: (context) => const PreferencesPage()),
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
