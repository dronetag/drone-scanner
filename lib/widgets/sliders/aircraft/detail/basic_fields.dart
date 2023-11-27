import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/proximity_alerts_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../models/aircraft_model_info.dart';
import '../../../../utils/utils.dart';
import '../../../app/dialogs.dart';
import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';
import 'aircraft_label_text.dart';

class BasicFields {
  static List<Widget> buildBasicFields({
    required BuildContext context,
    required List<MessageContainer> messagePackList,
    required AircraftModelInfo? modelInfo,
    required bool modelInfoFetchInProgress,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final idTypeString =
        messagePackList.last.basicIdMessage?.uasID.type.asString();
    final uaTypeString = messagePackList.last.basicIdMessage?.uaType.asString();

    final logo = getManufacturerLogo(
        manufacturer: modelInfo?.maker, color: AppColors.detailFieldColor);

    final uasId = messagePackList.last.basicIdMessage?.uasID;
    final proximityAlertsActive = context
        .watch<ProximityAlertsCubit>()
        .state
        .isAlertActiveForId(uasId?.asString());

    return [
      const Headline(text: 'AIRCRAFT'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Manufacturer',
            tooltipMessage: 'Manufacturer of your drone or RID device',
            child: modelInfoFetchInProgress
                ? _buildProgressIndicator(context)
                : Text.rich(
                    TextSpan(
                      children: [
                        if (logo != null)
                          TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: logo,
                              ),
                              TextSpan(
                                text: ' ',
                              ),
                            ],
                          ),
                        TextSpan(
                          text: modelInfo?.maker ?? '-',
                          style: const TextStyle(
                            color: AppColors.detailFieldColor,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          AircraftDetailField(
            headlineText: 'Model',
            fieldText: modelInfo?.model,
            tooltipMessage: 'Model name of your drone or RID device',
            child: modelInfoFetchInProgress
                ? _buildProgressIndicator(context)
                : null,
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'ID Type',
            fieldText: idTypeString,
          ),
          AircraftDetailField(
            headlineText: 'Type',
            fieldText: uaTypeString,
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AircraftDetailField(
                headlineText: 'UAS ID',
                fieldText:
                    messagePackList.last.basicIdMessage?.uasID.asString(),
              ),
              ElevatedButton(
                onPressed: () {
                  final alertsCubit = context.read<ProximityAlertsCubit>();
                  if (uasId?.asString() != null &&
                      alertsCubit.state.usersAircraftUASID ==
                          uasId!.asString()) {
                    alertsCubit.clearUsersAircraftUASID();
                    showSnackBar(context, 'Owned aircaft was unset');
                  } else {
                    if (uasId?.asString() == null) {
                      showSnackBar(context,
                          'Cannot set aircraft as owned: Unknown UAS ID');
                      return;
                    }
                    final validationError = validateUASID(uasId!.asString()!);
                    if (validationError != null) {
                      showSnackBar(
                          context, 'Error parsing UAS ID: $validationError');
                      FocusManager.instance.primaryFocus?.unfocus();
                      return;
                    }
                    alertsCubit.setUsersAircraftUASID(uasId.asString()!);
                    showSnackBar(context, 'Aircaft set as owned');
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    proximityAlertsActive ? AppColors.green : Colors.white,
                  ),
                  side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(
                        width: 2.0,
                        color: proximityAlertsActive
                            ? Colors.white
                            : AppColors.green),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: proximityAlertsActive ? 0 : Sizes.iconPadding,
                      ),
                      child: Icon(
                        Icons.person,
                        size: Sizes.iconSize,
                        color: proximityAlertsActive
                            ? Colors.white
                            : AppColors.green,
                      ),
                    ),
                    if (proximityAlertsActive)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: Sizes.iconPadding),
                        child: Icon(
                          Icons.done,
                          color: Colors.white,
                          size: Sizes.iconSize * 0.75,
                        ),
                      ),
                    Text(
                      proximityAlertsActive ? 'MINE' : 'SET AS MINE',
                      style: TextStyle(
                          fontSize: 12,
                          color: proximityAlertsActive
                              ? Colors.white
                              : AppColors.green),
                      textAlign: TextAlign.center,
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
          messagePackList.last.selfIdMessage?.description != null)
        AircraftDetailField(
          headlineText: 'Operation Description',
          fieldText: messagePackList.last.selfIdMessage!.description,
        ),
      if (isLandscape) const SizedBox(),
    ];
  }

  static Widget _buildProgressIndicator(BuildContext context) => Container(
      margin: EdgeInsets.only(
        left: Sizes.standard / 2,
        top: Sizes.standard / 2,
        bottom: Sizes.standard / 2,
      ),
      height: Sizes.standard * 1.5,
      width: Sizes.standard * 1.5,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: Theme.of(context).colorScheme.onPrimary,
      ));
}
