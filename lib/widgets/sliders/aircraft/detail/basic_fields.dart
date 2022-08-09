import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../../constants/colors.dart';
import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';
import 'aircraft_label_text.dart';

class BasicFields {
  static List<Widget> buildBasicFields(
    BuildContext context,
    List<MessagePack> messagePackList,
  ) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final idTypeString = messagePackList.last.basicIdMessage?.idType.toString();
    final uaTypeString = messagePackList.last.basicIdMessage?.uaType.toString();

    final idTypeLabel =
        idTypeString?.replaceAll('IdType.', '').replaceAll('_', ' ');
    final uaTypeLabel =
        uaTypeString?.replaceAll('UaType.', '').replaceAll('_', ' ');

    return [
      const Headline(text: 'AIRCRAFT'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'UA ID Type',
            fieldText: idTypeLabel,
          ),
          AircraftDetailField(
            headlineText: 'UA Type',
            fieldText: uaTypeLabel,
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AircraftDetailField(
                headlineText: 'UAS ID',
                fieldText: messagePackList.last.basicIdMessage == null
                    ? 'Unknown'
                    : '${messagePackList.last.basicIdMessage?.uasId}',
              ),
              const SizedBox(
                width: 10,
              ),
              if (messagePackList.last.basicIdMessage?.uasId
                      .startsWith('1596') ==
                  true)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.lightGray,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Image.asset(
                          'assets/images/dronetag.png',
                          height: 16,
                          width: 24,
                          alignment: Alignment.topCenter,
                          color: AppColors.lightGray,
                        ),
                      ),
                      const TextSpan(
                        text: 'Dronetag',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftLabelText(
            aircraftMac: messagePackList.last.macAddress,
          ),
        ],
      ),
      if (messagePackList.last.selfIdMessage != null &&
          messagePackList.last.selfIdMessage?.operationDescription != null)
        AircraftDetailField(
          headlineText: 'Operation Description',
          fieldText: messagePackList.last.selfIdMessage!.operationDescription,
        ),
    ];
  }
}
