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
  return showMenu<ToolbarMenuAction>(
    context: context,
    items: [
      if (context.read<StandardsCubit>().state.androidSystem)
        PopupMenuItem(
          value: ToolbarMenuAction.toggleWifi,
          padding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, setState) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: context.watch<OpendroneIdCubit>().state.isScanningWifi,
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
              title: const Text('Enable Wi-Fi'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
      PopupMenuItem(
        value: ToolbarMenuAction.toggleBT,
        padding: EdgeInsets.zero,
        child: StatefulBuilder(
          builder: (_context, _setState) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _context.watch<OpendroneIdCubit>().state.isScanningBluetooth,
            onChanged: (value) {
              _context
                  .read<OpendroneIdCubit>()
                  .setBtUsed(btUsed: value!)
                  .then((value) => _setState);
              late final String snackBarText;
              if (value) {
                snackBarText = 'Bluetooth Scanning Started.';
              } else {
                snackBarText = 'Bluetooth Scanning Stopped.';
              }
              showSnackBar(context, snackBarText);
            },
            title: const Text('Enable Bluetooth'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ),
      const PopupMenuDivider(
        height: 1,
      ),
      const PopupMenuItem(
        padding: EdgeInsets.only(
          left: Sizes.mapContentMargin,
        ),
        value: ToolbarMenuAction.openSettings,
        child: Text('Preferences'),
      ),
      const PopupMenuItem(
        padding: EdgeInsets.only(
          left: Sizes.mapContentMargin,
        ),
        value: ToolbarMenuAction.openAbout,
        child: Text('About'),
      ),
    ],
    position: RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height / 6,
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
