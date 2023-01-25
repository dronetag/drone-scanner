import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../constants/snackbar_messages.dart';
import '../../app/dialogs.dart';

class ScanningStateIcons extends StatelessWidget {
  const ScanningStateIcons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BlocBuilder<OpendroneIdCubit, ScanningState>(
          builder: (context, state) {
            return RawMaterialButton(
              onPressed: () {
                late final String snackBarText;
                context
                    .read<OpendroneIdCubit>()
                    .isBtTurnedOn()
                    .then((turnedOn) {
                  if (turnedOn) {
                    if (state.isScanningBluetooth &&
                        (state.usedTechnologies == UsedTechnologies.Bluetooth ||
                            state.usedTechnologies == UsedTechnologies.Both)) {
                      context.read<OpendroneIdCubit>().setBtUsed(btUsed: false);
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
                          snackBarText = unableToStartMessage(result.error!);
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
                              .androidSystem),
                    );
                  }
                });
              },
              //padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const CircleBorder(),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Icon(
                    Icons.bluetooth,
                    color: state.isScanningBluetooth
                        ? Colors.white
                        : AppColors.iconDisabledColor,
                    size: Sizes.iconSize,
                  ),
                  if (!state.isScanningBluetooth)
                    Transform.rotate(
                      angle: -math.pi / 4,
                      child: Container(
                        width: Sizes.iconSize / 8,
                        height: Sizes.iconSize + 3,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        // wifi not supported on iOS at all
        if (context.watch<StandardsCubit>().state.androidSystem)
          BlocBuilder<OpendroneIdCubit, ScanningState>(
            builder: (context, state) {
              return RawMaterialButton(
                onPressed: () {
                  late final String snackBarText;
                  context
                      .read<OpendroneIdCubit>()
                      .isWifiTurnedOn()
                      .then((turnedOn) {
                    if (turnedOn) {
                      if (state.isScanningWifi &&
                          (state.usedTechnologies == UsedTechnologies.Wifi ||
                              state.usedTechnologies ==
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
                            snackBarText = unableToStartMessage(result.error!);
                          }
                          showSnackBar(context, snackBarText);
                        });
                      }
                    } else {
                      snackBarText = wifiTurnedOffMessage;
                      showSnackBar(
                        context,
                        snackBarText,
                      );
                    }
                  });
                },
                //padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Image.asset(
                      'assets/images/wifi_icon.png',
                      width: Sizes.iconSize,
                      height: Sizes.iconSize,
                      color: state.isScanningWifi
                          ? Colors.white
                          : AppColors.iconDisabledColor,
                    ),
                    if (!state.isScanningWifi)
                      Transform.rotate(
                        angle: -math.pi / 4,
                        child: Container(
                          width: Sizes.iconSize / 8,
                          height: Sizes.iconSize + 3,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
