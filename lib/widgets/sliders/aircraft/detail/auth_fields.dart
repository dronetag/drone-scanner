import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class AuthFields {
  static List<Widget> buildAuthFields(
    BuildContext context,
    MessageContainer pack,
  ) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final authMessage = pack.authenticationMessage;

    return [
      const Headline(text: 'AUTHENTICATION'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Type',
            fieldText: authMessage?.authType.asString() ?? '-',
          ),
          AircraftDetailField(
            headlineText: 'Length',
            fieldText: authMessage?.authLength?.toString() ?? '-',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Page Number',
            fieldText: authMessage?.authPageNumber.toString() ?? '-',
          ),
          AircraftDetailField(
            headlineText: 'Last Page Index',
            fieldText: authMessage?.lastAuthPageIndex?.toString() ?? '-',
          ),
        ],
      ),
      AircraftDetailField(
          headlineText: 'Timestamp',
          fieldText: authMessage?.timestamp?.toLocal().toString() ?? '-'),
      AircraftDetailField(
        headlineText: 'Auth Data',
        fieldText: authMessage?.authData.toString() ?? '-',
      ),
    ];
  }
}
