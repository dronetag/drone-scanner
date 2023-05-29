import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;

import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../extensions/string_extensions.dart';
import '../../../../utils/utils.dart';
import '../../common/headline.dart';
import '../../common/icon_center_to_loc.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class OperatorFields {
  static bool locValid(pigeon.SystemDataMessage? sys) {
    return sys != null &&
        sys.operatorLatitude != INV_LAT &&
        sys.operatorLongitude != INV_LON &&
        sys.operatorLatitude <= MAX_LAT &&
        sys.operatorLongitude <= MAX_LON &&
        sys.operatorLatitude >= MIN_LAT &&
        sys.operatorLongitude >= MIN_LON;
  }

  static List<Widget> buildOperatorFields(
    BuildContext context,
    MessagePack pack,
  ) {
    final systemMessage = pack.systemDataMessage;
    final opMessage = pack.operatorIdMessage;
    String? countryCode;
    if (opMessage != null) {
      countryCode = getCountryCode(opMessage.operatorId);
    }
    double? distanceFromMe;
    late final String distanceText;
    final systemDataValid = systemMessage != null;
    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid &&
        systemDataValid &&
        locValid(systemMessage)) {
      distanceFromMe = calculateDistance(
        systemMessage.operatorLatitude,
        systemMessage.operatorLongitude,
        context.read<MapCubit>().state.userLocation.latitude,
        context.read<MapCubit>().state.userLocation.longitude,
      );
      if (distanceFromMe > 1) {
        distanceText = '${distanceFromMe.toStringAsFixed(3)} km';
      } else {
        distanceText = '${(distanceFromMe * 1000).toStringAsFixed(1)} m';
      }
    } else {
      distanceText = 'Unknown';
    }
    final locationText = systemMessage != null && locValid(systemMessage)
        ? '${systemMessage.operatorLatitude.toStringAsFixed(4)}, '
            '${systemMessage.operatorLongitude.toStringAsFixed(4)}'
        : 'Unknown';

    Widget? flag;
    if (countryCode != null &&
        context.read<StandardsCubit>().state.internetAvailable &&
        opMessage != null &&
        pack.operatorIDValid()) {
      flag = getFlag(countryCode);
    }
    final opIdText = pack.operatorIDSet()
        ? flag == null
            ? opMessage!.operatorId.removeNonAlphanumeric()
            : ' ${opMessage!.operatorId.removeNonAlphanumeric()}'
        : 'Unknown';
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return [
      const Headline(text: 'OPERATOR'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Operator ID',
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
                      color: AppColors.detailFieldColor,
                    ),
                    text: opIdText,
                  ),
                ],
              ),
            ),
          ),
          if (pack.operatorIDSet() && !pack.operatorIDValid())
            AircraftDetailField(
              headlineText: '',
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.warning_amber_sharp,
                        size: Sizes.flagSize,
                        color: AppColors.redIcon,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      style: const TextStyle(
                        color: AppColors.red,
                      ),
                      text: ' Invalid data',
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Distance from me',
            fieldText: distanceText,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.detailFieldHeaderColor,
                    ),
                  ),
                  Text(
                    locationText,
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
              if (systemDataValid && locValid(systemMessage))
                IconCenterToLoc(
                  onPressedCallback: () {
                    context.read<MapCubit>().centerToLocDouble(
                          systemMessage.operatorLatitude,
                          systemMessage.operatorLongitude,
                        );
                    context.read<SlidersCubit>().animatePanelToSnapPoint();
                  },
                ),
            ],
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Altitude Geod.',
            fieldText: systemDataValid &&
                    systemMessage.operatorAltitudeGeo.toInt() != INV_ALT
                ? '${systemMessage.operatorAltitudeGeo.toString()}  m'
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Location Type',
            fieldText: systemDataValid
                ? systemMessage.operatorLocationType
                    .toString()
                    .replaceAll('OperatorLocationType.', '')
                : 'Unknown',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Area Radius',
            fieldText: systemDataValid
                ? '${systemMessage.areaRadius.toString()}  m'
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Area Count',
            fieldText: systemDataValid
                ? systemMessage.areaCount.toString()
                : 'Unknown',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Area Ceiling',
            fieldText: systemDataValid
                ? getAltitudeAsString(systemMessage.areaCeiling)
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Area Floor',
            fieldText: systemDataValid
                ? getAltitudeAsString(systemMessage.areaFloor)
                : 'Unknown',
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Category',
            fieldText: systemDataValid
                ? systemMessage.category
                    .toString()
                    .replaceAll('AircraftCategory.', '')
                    .replaceAll('_', ' ')
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Class',
            fieldText: systemDataValid
                ? systemMessage.classValue
                    .toString()
                    .replaceAll('AircraftClass.', '')
                    .replaceAll('_', ' ')
                : 'Unknown',
          ),
        ],
      ),
    ];
  }
}
