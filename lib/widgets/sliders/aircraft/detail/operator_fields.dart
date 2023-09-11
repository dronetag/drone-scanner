import 'package:dart_opendroneid/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

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
  static bool locValid(SystemMessage? sys) {
    return sys != null &&
        sys.operatorLocation?.latitude != null &&
        sys.operatorLocation?.longitude != null &&
        sys.operatorLocation!.latitude != INV_LAT &&
        sys.operatorLocation!.longitude != INV_LON &&
        sys.operatorLocation!.latitude <= MAX_LAT &&
        sys.operatorLocation!.longitude <= MAX_LON &&
        sys.operatorLocation!.latitude >= MIN_LAT &&
        sys.operatorLocation!.longitude >= MIN_LON;
  }

  static List<Widget> buildOperatorFields(
    BuildContext context,
    MessageContainer pack,
  ) {
    final systemMessage = pack.systemDataMessage;
    final opMessage = pack.operatorIdMessage;
    String? countryCode;
    if (opMessage != null) {
      countryCode = getCountryCode(opMessage.operatorID);
    }
    double? distanceFromMe;
    late final String distanceText;
    final systemDataValid = systemMessage != null;
    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid &&
        systemDataValid &&
        locValid(systemMessage)) {
      distanceFromMe = calculateDistance(
        systemMessage.operatorLocation!.latitude,
        systemMessage.operatorLocation!.longitude,
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
        ? '${systemMessage.operatorLocation!.latitude.toStringAsFixed(4)}, '
            '${systemMessage.operatorLocation!.longitude.toStringAsFixed(4)}'
        : 'Unknown';

    Widget? flag;
    if (countryCode != null &&
        context.read<StandardsCubit>().state.internetAvailable &&
        opMessage != null &&
        pack.operatorIDValid) {
      flag = getFlag(countryCode);
    }
    final opIdText = pack.operatorIDSet
        ? flag == null
            ? opMessage!.operatorID.removeNonAlphanumeric()
            : ' ${opMessage!.operatorID.removeNonAlphanumeric()}'
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
          if (pack.operatorIDSet && !pack.operatorIDValid)
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
                    if (locValid(systemMessage)) {
                      context.read<MapCubit>().centerToLocDouble(
                            systemMessage.operatorLocation!.latitude,
                            systemMessage.operatorLocation!.longitude,
                          );
                    }
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
                    systemMessage.operatorAltitude != null &&
                    systemMessage.operatorAltitude?.toInt() != INV_ALT
                ? '${systemMessage.operatorAltitude?.toStringAsFixed(2)}  m'
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Location Type',
            fieldText: systemDataValid
                ? systemMessage.operatorLocationType.asString()
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
                ? systemMessage.uaClassification.uaCategoryEuropeString()
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Class',
            fieldText: systemDataValid
                ? systemMessage.uaClassification.uaClassEuropeString()
                : 'Unknown',
          ),
        ],
      ),
    ];
  }
}
