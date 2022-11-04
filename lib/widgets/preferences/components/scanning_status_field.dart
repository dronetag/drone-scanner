import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../app/dialogs.dart';
import 'preferences_slider.dart';

class ScanningStatusField extends StatelessWidget {
  const ScanningStatusField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final odidState = context.watch<OpendroneIdCubit>().state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PreferencesSlider(
                    getValue: () => odidState.isScanningBluetooth,
                    setValue: (c) {
                      late final String snackBarText;
                      context
                          .read<OpendroneIdCubit>()
                          .isBtTurnedOn()
                          .then((turnedOn) {
                        if (turnedOn) {
                          if (odidState.isScanningBluetooth &&
                              (odidState.usedTechnologies ==
                                      UsedTechnologies.Bluetooth ||
                                  odidState.usedTechnologies ==
                                      UsedTechnologies.Both)) {
                            context
                                .read<OpendroneIdCubit>()
                                .setBtUsed(btUsed: false);
                            snackBarText = 'Bluetooth Scanning Stopped.';
                          } else {
                            context
                                .read<OpendroneIdCubit>()
                                .setBtUsed(btUsed: true);
                            snackBarText = 'Bluetooth Scanning Started.';
                          }
                          showSnackBar(context, snackBarText);
                        } else {
                          snackBarText = 'Turn Bluetooth on to start scanning.';
                          showSnackBar(
                            context,
                            snackBarText,
                          );
                        }
                      });
                    },
                  ),
                  Icon(Icons.bluetooth),
                ],
              ),
              Text('Bluetooth'),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                PreferencesSlider(
                  getValue: () => odidState.isScanningWifi,
                  setValue: (c) {
                    late final String snackBarText;
                    context
                        .read<OpendroneIdCubit>()
                        .isWifiTurnedOn()
                        .then((turnedOn) {
                      if (turnedOn) {
                        if (odidState.isScanningWifi &&
                                odidState.usedTechnologies ==
                                    UsedTechnologies.Wifi ||
                            odidState.usedTechnologies ==
                                UsedTechnologies.Both) {
                          context
                              .read<OpendroneIdCubit>()
                              .setWifiUsed(wifiUsed: false);
                          snackBarText = 'Wi-Fi Scanning Stopped.';
                        } else {
                          context
                              .read<OpendroneIdCubit>()
                              .setWifiUsed(wifiUsed: true);
                          snackBarText = 'Wi-Fi Scanning Started.';
                        }
                        showSnackBar(context, snackBarText);
                      } else {
                        snackBarText = 'Turn Wi-Fi on to start scanning.';
                        showSnackBar(
                          context,
                          snackBarText,
                        );
                      }
                    });
                  },
                ),
                Icon(Icons.wifi),
              ],
            ),
            Text('Wi-Fi Beacon and NaN'),
          ],
        )
      ],
    );
  }
}
