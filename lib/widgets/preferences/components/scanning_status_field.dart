import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../app/dialogs.dart';
import 'preferences_slider.dart';

class ScanningStatusField extends StatelessWidget {
  const ScanningStatusField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      border: Border.all(
        color: AppColors.borderGray,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(5.0),
      ),
    );
    final odidState = context.watch<OpendroneIdCubit>().state;
    final textStyle = TextStyle(fontSize: 14);
    final wifiEnabled = context.read<StandardsCubit>().state.androidSystem;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.only(right: 5),
            padding: const EdgeInsets.all(20.0),
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            snackBarText =
                                'Turn Bluetooth on to start scanning.';
                            showSnackBar(
                              context,
                              snackBarText,
                            );
                          }
                        });
                      },
                    ),
                    Icon(
                      Icons.bluetooth,
                      color: AppColors.detailFieldHeaderColor,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text('Bluetooth', style: textStyle),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: AbsorbPointer(
            absorbing: !wifiEnabled,
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.lighten,
              ),
              decoration: decoration,
              margin: EdgeInsets.only(left: 5),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Image.asset(
                        'assets/images/wifi_icon.png',
                        width: Sizes.iconSize,
                        height: Sizes.iconSize,
                        color: AppColors.detailFieldHeaderColor,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Wi-Fi Beacon & NaN',
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
