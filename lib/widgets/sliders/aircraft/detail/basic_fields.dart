import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../../bloc/proximity_alerts_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../utils/uasid_prefix_reader.dart';
import '../../../../utils/utils.dart';
import '../../../app/dialogs.dart';
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
    String? manufacturer;
    Image? logo;
    if (messagePackList.isNotEmpty &&
        messagePackList.last.basicIdMessage != null) {
      manufacturer = UASIDPrefixReader.getManufacturerFromUASID(
          messagePackList.last.basicIdMessage!.uasId);
      logo = getManufacturerLogo(
          manufacturer: manufacturer, color: AppColors.lightGray);
    }
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
              if (logo != null && manufacturer != null)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.lightGray,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: logo,
                      ),
                      TextSpan(
                        text: manufacturer,
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
      AircraftDetailRow(
        children: [
          Text(
            'This aircraft is mine',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 20,
              height: 20,
              child: Checkbox(
                value: context
                            .watch<ProximityAlertsCubit>()
                            .state
                            .usersAircraftUASID !=
                        null &&
                    context
                            .watch<ProximityAlertsCubit>()
                            .state
                            .usersAircraftUASID ==
                        messagePackList.last.basicIdMessage?.uasId,
                onChanged: (value) {
                  if (value == null) return;
                  final uasId = messagePackList.last.basicIdMessage?.uasId;
                  if (value && uasId != null) {
                    final validationError = validateUASID(uasId);
                    if (validationError != null) {
                      showSnackBar(
                          context, 'Error parsing UAS ID: $validationError');
                      FocusManager.instance.primaryFocus?.unfocus();
                      return;
                    }
                    context
                        .read<ProximityAlertsCubit>()
                        .setUsersAircraftUASID(uasId);
                    showSnackBar(context, 'Aircaft set as owned');
                  } else {
                    context
                        .read<ProximityAlertsCubit>()
                        .clearUsersAircraftUASID();
                  }
                },
                fillColor: MaterialStateProperty.all<Color>(
                  AppColors.highlightBlue,
                ),
              ),
            ),
          )
        ],
      ),
      if (messagePackList.last.selfIdMessage != null &&
          messagePackList.last.selfIdMessage?.operationDescription != null)
        AircraftDetailField(
          headlineText: 'Operation Description',
          fieldText: messagePackList.last.selfIdMessage!.operationDescription,
        ),
      if (isLandscape) const SizedBox(),
    ];
  }
}
