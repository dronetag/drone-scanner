import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../utils/utils.dart';
import '../common/refreshing_text.dart';
import 'aircraft_card_custom_text.dart';
import 'aircraft_card_title.dart';

class AircraftCard extends StatelessWidget {
  final MessagePack messagePack;

  const AircraftCard({
    Key? key,
    required this.messagePack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countryCode =
        messagePack.operatorIdMessage?.operatorId.substring(0, 2);
    final isAirborne =
        messagePack.locationMessage?.status == pigeon.AircraftStatus.Airborne;

    final givenLabel =
        context.read<AircraftCubit>().getAircraftLabel(messagePack.macAddress);

    Image? flag;
    if (messagePack.operatorIDValid() &&
        countryCode != null &&
        context.watch<StandardsCubit>().state.internetAvailable) {
      try {
        flag = Image.network(
          'https://flagcdn.com/h20/${countryCode.toLowerCase()}.png',
          width: 24,
          height: 12,
          alignment: Alignment.centerLeft,
        );
      } on Exception {
        flag = null;
      }
    }
    final uasIdText = messagePack.basicIdMessage != null &&
            messagePack.basicIdMessage?.uasId != ''
        ? messagePack.basicIdMessage!.uasId
        : 'Unknown UAS ID';

    return Opacity(
      opacity: isAirborne ? 1.0 : 0.75,
      child: ListTile(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.zero,
        leading: buildLeading(context),
        trailing: buildTrailing(context),
        title: AircraftCardTitle(
          uasId: uasIdText,
          givenLabel: givenLabel,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operator ID row
            Text.rich(
              TextSpan(
                children: [
                  if (countryCode != null &&
                      flag != null &&
                      messagePack.operatorIDValid())
                    WidgetSpan(
                      child: flag,
                      alignment: PlaceholderAlignment.middle,
                    ),
                  TextSpan(
                    text: messagePack.operatorIDValid()
                        ? ' ${messagePack.operatorIdMessage?.operatorId}'
                        : 'Unknown Operator ID',
                  ),
                ],
              ),
            ),
            AircraftCardCustomText(
              messagePack: messagePack,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isAirborne =
        messagePack.locationMessage?.status == pigeon.AircraftStatus.Airborne;
    final icon = isAirborne ? Icons.flight_takeoff : Icons.flight_land;
    final aircraftText = messagePack.locationMessage == null ||
            messagePack.locationMessage!.status == pigeon.AircraftStatus.Ground
        ? 'Grounded'
        : '${messagePack.locationMessage!.height.toString()} m';
    return SizedBox(
      width: width / 8,
      child: Column(
        children: [
          Icon(
            icon,
            color: isAirborne ? AppColors.highlightBlue : AppColors.dark,
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            aircraftText,
            style: TextStyle(
              color: isAirborne ? AppColors.highlightBlue : AppColors.dark,
            ),
            textScaleFactor: 0.7,
          ),
        ],
      ),
    );
  }

  Widget buildTrailing(BuildContext context) {
    final loc = messagePack.locationMessage;
    if (messagePack.basicIdMessage != null &&
        messagePack.basicIdMessage?.uaType != null) {
      // to-do: icon according to basic.uaType
    }
    final rssi = messagePack.lastMessageRssi;
    final source = messagePack.getPackSource();
    final standardText = getSourceShortcut(source);
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width / 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                source == pigeon.MessageSource.BluetoothLegacy ||
                        source == pigeon.MessageSource.BluetoothLongRange
                    ? Icons.bluetooth
                    : Icons.wifi,
                size: Sizes.iconSize / 3 * 2,
              ),
              Text(
                standardText,
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Text(
            (loc == null || loc.latitude == null || loc.longitude == null)
                ? "${rssi ?? "?"} dBm"
                : "${rssi ?? "?"} dBm",
            textScaleFactor: 0.7,
          ),
          RefreshingText(pack: messagePack, scaleFactor: 0.7, short: true),
        ],
      ),
    );
  }
}
