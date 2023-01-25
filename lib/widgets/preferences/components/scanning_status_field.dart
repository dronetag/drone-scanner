import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../constants/snackbar_messages.dart';
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
    final contentPadding = const EdgeInsets.all(15.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 5),
              padding: contentPadding,
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
                          context
                              .read<OpendroneIdCubit>()
                              .isBtTurnedOn()
                              .then((turnedOn) {
                            if (turnedOn) {
                              late final String snackBarText;
                              if (odidState.isScanningBluetooth &&
                                  (odidState.usedTechnologies ==
                                          UsedTechnologies.Bluetooth ||
                                      odidState.usedTechnologies ==
                                          UsedTechnologies.Both)) {
                                context
                                    .read<OpendroneIdCubit>()
                                    .setBtUsed(btUsed: false);
                                snackBarText = btScanStopMessage;
                                showSnackBar(context, snackBarText);
                              } else {
                                context
                                    .read<OpendroneIdCubit>()
                                    .setBtUsed(btUsed: true)
                                    .then((result) {
                                  if (result.success) {
                                    snackBarText = btScanStartMessage;
                                  } else {
                                    snackBarText =
                                        unableToStartMessage(result.error!);
                                  }
                                  showSnackBar(context, snackBarText);
                                });
                              }
                            } else {
                              showSnackBar(
                                context,
                                btTurnedOffMessage(
                                  isAndroidSystem: context
                                      .read<StandardsCubit>()
                                      .state
                                      .androidSystem,
                                ),
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
            child: AbsorbPointer(
              absorbing: !wifiEnabled,
              child: Opacity(
                opacity: wifiEnabled ? 1 : 0.5,
                child: Container(
                  decoration: decoration,
                  margin: EdgeInsets.only(left: 5),
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PreferencesSlider(
                            getValue: () => odidState.isScanningWifi,
                            setValue: (c) {
                              context
                                  .read<OpendroneIdCubit>()
                                  .isWifiTurnedOn()
                                  .then((turnedOn) {
                                if (turnedOn) {
                                  late final String snackBarText;
                                  if (odidState.isScanningWifi &&
                                      (odidState.usedTechnologies ==
                                              UsedTechnologies.Wifi ||
                                          odidState.usedTechnologies ==
                                              UsedTechnologies.Both)) {
                                    context
                                        .read<OpendroneIdCubit>()
                                        .setWifiUsed(wifiUsed: false);
                                    snackBarText = wifiScanStopMessage;
                                    showSnackBar(context, snackBarText);
                                  } else {
                                    context
                                        .read<OpendroneIdCubit>()
                                        .setWifiUsed(wifiUsed: true)
                                        .then((result) {
                                      if (result.success) {
                                        snackBarText = wifiScanStartMessage;
                                      } else {
                                        snackBarText =
                                            unableToStartMessage(result.error!);
                                      }
                                      showSnackBar(context, snackBarText);
                                    });
                                  }
                                } else {
                                  showSnackBar(
                                    context,
                                    wifiTurnedOffMessage,
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
            ),
          ),
        ],
      ),
    );
  }
}
