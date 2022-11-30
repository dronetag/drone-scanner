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
    String? countryCode;
    if (messagePack.operatorIdMessage != null) {
      countryCode = getCountryCode(messagePack.operatorIdMessage!.operatorId);
    }

    final givenLabel =
        context.read<AircraftCubit>().getAircraftLabel(messagePack.macAddress);

    Widget? flag;

    if (context.read<StandardsCubit>().state.internetAvailable &&
        messagePack.operatorIDValid() &&
        countryCode != null &&
        context.watch<StandardsCubit>().state.internetAvailable) {
      flag = getFlag(countryCode);
    }
    final uasIdText = messagePack.basicIdMessage != null &&
            messagePack.basicIdMessage?.uasId != ''
        ? messagePack.basicIdMessage!.uasId
        : 'Unknown UAS ID';

    final opIdText = messagePack.operatorIDValid()
        ? flag == null
            ? messagePack.operatorIdMessage?.operatorId
            : ' ${messagePack.operatorIdMessage?.operatorId}'
        : 'Unknown Operator ID';

    return ListTile(
      minLeadingWidth: 0,
      horizontalTitleGap: 0,
      minVerticalPadding: 2,
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (countryCode != null &&
                    flag != null &&
                    messagePack.operatorIDValid())
                  WidgetSpan(
                    child: flag,
                    alignment: PlaceholderAlignment.middle,
                  ),
                TextSpan(
                  text: opIdText,
                ),
              ],
            ),
          ),
          AircraftCardCustomText(
            messagePack: messagePack,
          ),
        ],
      ),
    );
  }

  Widget buildLeading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final status = messagePack.locationMessage?.status;

    final icon = status == pigeon.AircraftStatus.Undeclared
        ? null
        : Image.asset(
            status == pigeon.AircraftStatus.Airborne
                ? 'assets/images/plane_airborne.png'
                : 'assets/images/plane_grounded.png',
            width: Sizes.cardIconSize,
            height: Sizes.cardIconSize,
          );

    final aircraftText = _getAircraftText();
    return Container(
      width: width / 6,
      margin: EdgeInsets.only(right: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  Icons.help_outline,
                  size: Sizes.cardIconSize,
                ),
            Text(
              aircraftText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.0,
                color: status == pigeon.AircraftStatus.Airborne
                    ? AppColors.highlightBlue
                    : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrailing(BuildContext context) {
    if (messagePack.basicIdMessage != null &&
        messagePack.basicIdMessage?.uaType != null) {
      // to-do: icon according to basic.uaType
    }
    final rssi = messagePack.lastMessageRssi;
    final source = messagePack.getPackSource();
    final standardText = getSourceShortcut(source);
    final width = MediaQuery.of(context).size.width;
    final iconSize = Sizes.iconSize / 3 * 2;
    return SizedBox(
      width: width / 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (source == pigeon.MessageSource.BluetoothLegacy ||
                  source == pigeon.MessageSource.BluetoothLongRange)
                Icon(
                  Icons.bluetooth,
                  size: iconSize,
                  color: AppColors.slate,
                ),
              if (source == pigeon.MessageSource.WifiBeacon ||
                  source == pigeon.MessageSource.WifiNaN)
                Image.asset(
                  'assets/images/wifi_icon.png',
                  color: AppColors.slate,
                  width: iconSize,
                  height: iconSize,
                ),
              Text(
                standardText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
          Text(
            "${rssi ?? "?"} dBm",
            textScaleFactor: 0.7,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
          RefreshingText(
            pack: messagePack,
            scaleFactor: 0.7,
            short: true,
            showExpiryWarning: true,
            fontWeight: FontWeight.w600,
            textColor: AppColors.slate,
          ),
        ],
      ),
    );
  }

  String _getAircraftText() {
    if (messagePack.locationMessage == null) return 'Unknown';
    final status = messagePack.locationMessage!.status;
    return status == pigeon.AircraftStatus.Ground
        ? 'Grounded'
        : status == pigeon.AircraftStatus.Airborne
            ? '${messagePack.locationMessage!.height.toString()}m AGL'
            : 'Unknown';
  }
}
