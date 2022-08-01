import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';

import '../../../bloc/opendroneid_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../app/dialogs.dart';

class ScanningStateIcons extends StatelessWidget {
  const ScanningStateIcons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    if (state.usedTechnologies == UsedTechnologies.Bluetooth ||
                        state.usedTechnologies == UsedTechnologies.Both) {
                      context.read<OpendroneIdCubit>().setBtUsed(btUsed: false);
                      snackBarText = 'Bluetooth Scanning Stopped.';
                    } else {
                      context.read<OpendroneIdCubit>().setBtUsed(btUsed: true);
                      snackBarText = 'Bluetooth Scanning Started.';
                    }
                    showSnackBar(context, snackBarText);
                  } else {
                    snackBarText = 'Turn Bluetooth on to start scanning.';
                    showSnackBar(
                      context,
                      snackBarText,
                      textColor: AppColors.droneScannerRed,
                    );
                  }
                });
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const CircleBorder(),
              child: Icon(
                state.isScanningBluetooth
                    ? Icons.bluetooth
                    : Icons.bluetooth_disabled,
                color: Colors.white,
                size: Sizes.iconSize,
              ),
            );
          },
        ),
        const SizedBox(
          width: 5,
        ),
        // wifi not supported on iOS at all
        if (context.watch<StandardsCubit>().state.androidSystem)
          BlocBuilder<OpendroneIdCubit, ScanningState>(
            builder: (context, state) {
              return RawMaterialButton(
                onPressed: () {
                  late final String snackBarText;
                  if (state.usedTechnologies == UsedTechnologies.Wifi ||
                      state.usedTechnologies == UsedTechnologies.Both) {
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
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(),
                child: Icon(
                  state.isScanningWifi ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: Sizes.iconSize,
                ),
              );
            },
          ),
      ],
    );
  }
}
