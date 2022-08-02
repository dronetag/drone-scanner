import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                    Icon(
                      source == MessageSource.BluetoothLegacy ||
                              source == MessageSource.BluetoothLongRange
                          ? Icons.bluetooth
                          : Icons.wifi,
                      size: Sizes.iconSize / 3 * 2,
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
                    color: AppColors.droneScannerDetailFieldColor,
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
                  color: AppColors.droneScannerHighlightBlue,
                  size: Sizes.iconSize / 3 * 2,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${messagePackList.last.lastMessageRssi} dBm',
                  style: const TextStyle(
                    color: AppColors.droneScannerDetailFieldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: context.read<StandardsCubit>().state.androidSystem
                ? 'Mac Address'
                : 'Identifier',
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
          ),
          AircraftDetailField(
            headlineText: 'Received',
            fieldText: '${messagePackList.length} messages',
          ),
        ],
      ),
      if (isLandscape) const Spacer(),
    ];
  }
}
