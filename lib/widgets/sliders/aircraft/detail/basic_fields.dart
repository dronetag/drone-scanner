import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/proximity_alerts_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../models/aircraft_model_info.dart';
import '../../common/headline.dart';
import '../../common/manufacturer_logo.dart';
import '../../common/small_circular_progress_indicator.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';
import 'aircraft_label_text.dart';
import 'set_as_mine_button.dart';

class BasicFields {
  static List<Widget> buildBasicFields({
    required BuildContext context,
    required List<MessageContainer> messagePackList,
    required AircraftModelInfo? modelInfo,
    required bool modelInfoFetchInProgress,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final logo = modelInfo?.maker != null
        ? ManufacturerLogo(
            manufacturer: modelInfo!.maker, color: AppColors.detailFieldColor)
        : null;

    final basicIdFields = _buildBasicIdMessages(
        context: context, messageContainer: messagePackList.last);

    return [
      const Headline(text: 'AIRCRAFT'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Manufacturer',
            tooltipMessage: 'Aircraft manufacturer, estimated from the UAS ID',
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
                              const TextSpan(
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
            tooltipMessage: 'Aircraft model, estimated from the UAS ID',
            child: modelInfoFetchInProgress
                ? _buildProgressIndicator(context)
                : null,
          ),
        ],
      ),
      ...basicIdFields,
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

  static List<Widget> _buildBasicIdMessages({
    required BuildContext context,
    required MessageContainer messageContainer,
  }) {
    final basicIdFields = <Widget>[];
    if (messageContainer.basicIdMessages != null &&
        messageContainer.basicIdMessages!.isNotEmpty) {
      for (final (index, basicIdMessage)
          in messageContainer.basicIdMessages!.values.indexed) {
        basicIdFields.addAll(
          _buildBasicIdMessageFields(
            context: context,
            message: basicIdMessage,
            isPreferredBasicId:
                basicIdMessage == messageContainer.preferredBasicIdMessage,
            basicIdIndex: index + 1,
            shownHeadline: messageContainer.basicIdMessages!.length > 1,
          ),
        );
      }
    }
    // if there are no basic id messages, build empty fields once
    else {
      basicIdFields.addAll(_buildBasicIdMessageFields(
        context: context,
        message: null,
        isPreferredBasicId: false,
        shownHeadline: false,
      ));
    }
    return basicIdFields;
  }

  static List<Widget> _buildBasicIdMessageFields({
    required BuildContext context,
    required BasicIDMessage? message,
    required bool isPreferredBasicId,
    required bool shownHeadline,
    int? basicIdIndex,
  }) {
    final uaTypeString = message?.uaType.asString();
    final proximityAlertsActive = context
        .watch<ProximityAlertsCubit>()
        .state
        .isAlertActiveForId(message?.uasID.asString());

    return [
      if (shownHeadline)
        Headline(
          text: 'Identification ${basicIdIndex ?? ''}',
          dividerThickness: 0.5,
          fontSize: 14,
        ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: message?.uasID.type.asString() ?? 'UAS ID',
            fieldText: message?.uasID.asString(),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Type',
            fieldText: uaTypeString,
          ),
          if (isPreferredBasicId && message != null)
            Padding(
              padding: const EdgeInsets.only(left: Sizes.standard * 2),
              child: SetAsMineButton(
                uasId: message.uasID,
                proximityAlertsActive: proximityAlertsActive,
              ),
            )
        ],
      ),
    ];
  }

  static Widget _buildProgressIndicator(BuildContext context) =>
      const SmallCircularProgressIndicator(
        size: Sizes.standard * 1.5,
        margin: EdgeInsets.only(
          left: Sizes.standard / 2,
          top: Sizes.standard / 2,
          bottom: Sizes.standard / 2,
        ),
      );
}
