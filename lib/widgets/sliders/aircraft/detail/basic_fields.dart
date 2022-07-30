import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../../constants/colors.dart';
import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class BasicFields {
  static List<Widget> buildBasicFields(
    BuildContext context,
    List<MessagePack> messagePackList,
  ) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return [
      const Headline(text: 'AIRCRAFT'),
      if (isLandscape) const SizedBox(),
      if (messagePackList.last.basicIdMessage?.idType != null)
        AircraftDetailRow(
          children: [
            AircraftDetailField(
              headlineText: 'UA ID Type',
              fieldText:
                  '${messagePackList.last.basicIdMessage?.idType.toString().replaceAll("IdType.", "").replaceAll("_", " ")}',
            ),
            if (messagePackList.last.basicIdMessage?.uaType != null)
              AircraftDetailField(
                headlineText: 'UA Type',
                fieldText:
                    '${messagePackList.last.basicIdMessage?.uaType.toString().replaceAll("UaType.", "").replaceAll("_", " ")}',
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
              SizedBox(
                width: 10,
              ),
              if (messagePackList.last.basicIdMessage?.uasId
                      .startsWith('1596') ==
                  true)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.droneScannerLightGray,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Image.asset(
                          'assets/images/dronetag.png',
                          height: 16,
                          width: 24,
                          alignment: Alignment.topCenter,
                          color: AppColors.droneScannerLightGray,
                        ),
                      ),
                      TextSpan(
                        text: 'Dronetag Mini',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      if (messagePackList.last.selfIdMessage != null &&
          messagePackList.last.selfIdMessage?.operationDescription != null)
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Operation Description:'),
        ),
      if (messagePackList.last.selfIdMessage != null &&
          messagePackList.last.selfIdMessage?.operationDescription != null)
        Align(
          alignment: Alignment.centerRight,
          child: Text(messagePackList.last.selfIdMessage?.operationDescription
              as String),
        ),
    ];
  }
}
