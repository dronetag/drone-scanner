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
    final isAirborne =
        messagePack.locationMessage?.status == pigeon.AircraftStatus.Airborne;
    final icon = Image.asset(
      isAirborne
          ? 'assets/images/plane_airborne.png'
          : 'assets/images/plane_grounded.png',
      width: Sizes.cardIconSize,
      height: Sizes.cardIconSize,
    );
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final aircraftText = messagePack.locationMessage == null ||
            messagePack.locationMessage!.status == pigeon.AircraftStatus.Ground
        ? 'Grounded'
        : '${messagePack.locationMessage!.height.toString()}m AGL';
    return SizedBox(
      width: width / 6,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          direction: isLandscape ? Axis.vertical : Axis.horizontal,
          children: [
            Padding(padding: EdgeInsets.only(left: 6.0), child: icon),
            const SizedBox(
              height: 2,
            ),
            Text(
              aircraftText,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.0,
                color: isAirborne ? AppColors.highlightBlue : AppColors.dark,
              ),
            ),
          ],
        ),
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
            (loc == null || loc.latitude == null || loc.longitude == null)
                ? "${rssi ?? "?"} dBm"
                : "${rssi ?? "?"} dBm",
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
}
