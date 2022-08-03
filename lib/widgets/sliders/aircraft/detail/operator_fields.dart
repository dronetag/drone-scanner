import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;

import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../utils/utils.dart';
import '../../common/headline.dart';
import '../../common/icon_center_to_loc.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class OperatorFields {
  static List<Widget> buildOperatorFields(
    BuildContext context,
    pigeon.SystemDataMessage systemMessage,
    pigeon.OperatorIdMessage? opMessage,
  ) {
    final countryCode = opMessage?.operatorId.substring(0, 2);

    Image? flag;
    if (countryCode != null) flag = getFlag(countryCode);

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return [
      const Headline(text: 'OPERATOR'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Operator ID',
            //fieldText: opMessage.operatorId,
            child: Text.rich(
              TextSpan(
                children: [
                  if (flag != null)
                    WidgetSpan(
                      child: flag,
                      alignment: PlaceholderAlignment.middle,
                    ),
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.droneScannerDetailFieldColor,
                    ),
                    text: opMessage != null
                        ? opMessage.operatorId
                        : 'Unknown Operator ID',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Location',
            fieldText: '${systemMessage.operatorLatitude.toStringAsFixed(3)}, '
                '${systemMessage.operatorLongitude.toStringAsFixed(3)}',
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconCenterToLoc(
              onPressedCallback: () {
                context.read<MapCubit>().centerToLocDouble(
                      systemMessage.operatorLatitude,
                      systemMessage.operatorLongitude,
                    );
                context
                    .read<SlidersCubit>()
                    .panelController
                    .animatePanelToSnapPoint();
              },
            ),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Op. Location Type',
            fieldText: systemMessage.operatorLocationType
                .toString()
                .replaceAll('OperatorLocationType.', ''),
          ),
          AircraftDetailField(
            headlineText: 'Altitude',
            fieldText: '${systemMessage.operatorAltitudeGeo.toString()}  m',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Area Radius',
            fieldText: '${systemMessage.areaRadius.toString()}  m',
          ),
          AircraftDetailField(
            headlineText: 'Area Count',
            fieldText: systemMessage.areaCount.toString(),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Area Ceiling',
            fieldText: '${systemMessage.areaCeiling.toString()}  m',
          ),
          AircraftDetailField(
            headlineText: 'Area Floor',
            fieldText: '${systemMessage.areaFloor.toString()} m',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Category',
            fieldText: systemMessage.category
                .toString()
                .replaceAll('AircraftCategory.', ''),
          ),
          AircraftDetailField(
            headlineText: 'Class',
            fieldText: systemMessage.classValue
                .toString()
                .replaceAll('AircraftClass.', ''),
          ),
        ],
      ),
    ];
  }
}
