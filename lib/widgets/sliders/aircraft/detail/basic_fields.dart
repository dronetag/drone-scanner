import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class BasicFields {
  static List<Widget> buildBasicFields(
      BuildContext context, List<MessagePack> messagePackList) {
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
          AircraftDetailField(
            headlineText: 'UAS ID',
            fieldText: messagePackList.last.basicIdMessage == null
                ? 'Unknown'
                : '${messagePackList.last.basicIdMessage?.uasId}',
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
