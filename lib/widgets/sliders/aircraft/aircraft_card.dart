import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../extensions/string_extensions.dart';
import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/aircraft_metadata_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/message_container_authenticity_status.dart';
import '../../../utils/utils.dart';
import '../common/flag.dart';
import '../common/refreshing_text.dart';
import 'aircraft_card_custom_text.dart';
import 'aircraft_card_title.dart';

class AircraftCard extends StatelessWidget {
  final MessageContainer messagePack;

  const AircraftCard({
    super.key,
    required this.messagePack,
  });

  @override
  Widget build(BuildContext context) {
    final givenLabel = context
        .read<AircraftMetadataCubit>()
        .getAircraftLabel(messagePack.macAddress);

    final uasId = messagePack.preferredBasicIdMessage?.uasID;
    final uasIdText = uasId?.asString() ?? 'Unknown UAS ID';

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
      subtitle: buildSubtitle(context),
    );
  }

  Widget buildLeading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final status = messagePack.locationMessage?.status;
    final proximityAlertsState = context.read<ProximityAlertsCubit>().state;
    final proximityAlertsActive = messagePack.basicIdMessages?.values.any(
            (element) => proximityAlertsState
                .isAlertActiveForId(element.uasID.asString())) ??
        false;

    final icon = status == OperationalStatus.none
        ? null
        : Image.asset(
            status == OperationalStatus.airborne
                ? 'assets/images/plane_airborne.png'
                : 'assets/images/plane_grounded.png',
            width: Sizes.cardIconSize,
            height: Sizes.cardIconSize,
            color: proximityAlertsActive ? AppColors.green : null,
          );

    final aircraftText = _getAircraftText();
    return Container(
      width: width / 6,
      margin: const EdgeInsets.only(right: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ??
                const Icon(
                  Icons.help_outline,
                  size: Sizes.cardIconSize,
                ),
            Text(
              aircraftText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.0,
                color: proximityAlertsActive
                    ? AppColors.green
                    : status == OperationalStatus.airborne
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
    // TODO: icon according to basic.uaType

    final rssi = messagePack.lastMessageRssi;
    final source = messagePack.packSource;
    final standardText = getSourceShortcut(source);

    final width = MediaQuery.of(context).size.width;
    const iconSize = Sizes.iconSize / 3 * 2;
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
                const Icon(
                  Icons.bluetooth,
                  size: iconSize,
                  color: AppColors.slate,
                ),
              if (source == pigeon.MessageSource.WifiBeacon ||
                  source == pigeon.MessageSource.WifiNan)
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
            textScaler: const TextScaler.linear(0.7),
            style: const TextStyle(
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

  Widget buildSubtitle(BuildContext context) {
    String? countryCode;
    Widget? flag;

    if (messagePack.operatorIDSet && messagePack.operatorIDValid) {
      countryCode = getCountryCode(messagePack.operatorIdMessage!.operatorID);
    }

    final internetAvailable = context
        .select<StandardsCubit, bool>((cubit) => cubit.state.internetAvailable);
    if (countryCode != null && internetAvailable) {
      flag = Flag(
        alpha3CountryCode: countryCode,
        margin: const EdgeInsets.only(right: Sizes.standard / 2),
      );
    }

    final authenticityStatus =
        context.select<AircraftCubit, MessageContainerAuthenticityStatus>(
      (cubit) =>
          cubit.state.dataAuthenticityStatuses[messagePack.macAddress] ??
          MessageContainerAuthenticityStatus.untrusted,
    );

    final opIdTrimmed =
        messagePack.operatorIdMessage?.operatorID.removeNonAlphanumeric();
    final opIdText =
        messagePack.operatorIDSet ? opIdTrimmed : 'Unknown Operator ID';

    return Column(
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
                  messagePack.operatorIDSet)
                WidgetSpan(
                  child: flag,
                  alignment: PlaceholderAlignment.middle,
                ),
              TextSpan(
                text: opIdText,
              ),
              if (messagePack.operatorIDSet &&
                  !messagePack.operatorIDValid) ...[
                const TextSpan(text: ' '),
                const WidgetSpan(
                  child: Icon(
                    Icons.warning_amber_sharp,
                    size: Sizes.flagSize,
                    color: AppColors.redIcon,
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ],
          ),
        ),
        AircraftCardCustomText(
          messagePack: messagePack,
        ),
        if (authenticityStatus.shouldBeDisplayed)
          Text(
            authenticityStatus.name.capitalize(),
            textScaler: const TextScaler.linear(0.9),
          )
      ],
    );
  }

  String _getAircraftText() {
    if (messagePack.locationMessage == null) return 'Unknown';
    final status = messagePack.locationMessage!.status;
    return status == OperationalStatus.ground
        ? 'Grounded'
        : status == OperationalStatus.airborne
            ? '${messagePack.locationMessage!.height.toString()}m AGL'
            : 'Unknown';
  }
}
