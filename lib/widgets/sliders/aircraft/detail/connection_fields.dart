import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import '../../../../bloc/standards_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../utils/utils.dart';
import '../../common/headline.dart';
import '../aircraft_refreshing_field.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class ConnectionFields {
  static List<Widget> buildConnectionFields(
    BuildContext context,
    List<MessagePack> messagePackList,
  ) {
    final source = messagePackList.last.getPackSource();
    final sourceText = getSourceText(source);
    final sourceShortcut = getSourceShortcut(source);

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return [
      const Headline(text: 'CONNECTION'),
      if (isLandscape) const Spacer(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Type',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (source == MessageSource.BluetoothLegacy ||
                        source == MessageSource.BluetoothLongRange)
                      Icon(
                        Icons.bluetooth,
                        size: Sizes.iconSize / 3 * 2,
                      ),
                    if (source == MessageSource.WifiBeacon ||
                        source == MessageSource.WifiNaN)
                      Image.asset(
                        'assets/images/wifi_icon.png',
                        width: Sizes.iconSize / 3 * 2,
                        height: Sizes.iconSize / 3 * 2,
                      ),
                    Text(
                      sourceShortcut,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  sourceText,
                  style: const TextStyle(
                    color: AppColors.detailFieldColor,
                  ),
                ),
              ],
            ),
          ),
          AircraftDetailField(
            headlineText: 'Signal Strength (RSSI)',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.signal_cellular_alt,
                  color: AppColors.highlightBlue,
                  size: Sizes.iconSize / 3 * 2,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${messagePackList.last.lastMessageRssi} dBm',
                  style: const TextStyle(
                    color: AppColors.detailFieldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      if (context.read<StandardsCubit>().state.androidSystem)
        AircraftDetailRow(
          children: [
            AircraftDetailField(
              headlineText: 'Mac Address',
              fieldText: messagePackList.last.macAddress,
            ),
          ],
        ),
      AircraftDetailRow(
        children: [
          AircraftRefresingField(
            pack: messagePackList.first,
            label: 'First Seen',
          ),
          AircraftRefresingField(
            pack: messagePackList.last,
            label: 'Last Seen',
            showExpiryWarning: true,
          ),
          AircraftDetailField(
            headlineText: '# Messages',
            fieldText: '${messagePackList.length}',
          ),
        ],
      ),
      if (isLandscape) const Spacer(),
    ];
  }
}
