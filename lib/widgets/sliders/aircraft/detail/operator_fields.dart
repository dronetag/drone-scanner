import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
import '../../../../bloc/units_settings_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../extensions/string_extensions.dart';
import '../../../../models/unit_value.dart';
import '../../../../utils/utils.dart';
import '../../common/flag.dart';
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
    final unitsSettingsCubit = context.read<UnitsSettingsCubit>();

    final systemMessage = pack.systemDataMessage;
    final systemDataValid = systemMessage != null;

    final opMessage = pack.operatorIdMessage;
    String? countryCode;
    if (opMessage != null) {
      countryCode = getCountryCode(opMessage.operatorID);
    }
    final distanceText = _getDistanceText(context, systemMessage);

    final locationText = systemMessage != null && locValid(systemMessage)
        ? '${systemMessage.operatorLocation!.latitude.toStringAsFixed(4)}, '
            '${systemMessage.operatorLocation!.longitude.toStringAsFixed(4)}'
        : 'Unknown';

    Widget? flag;
    if (countryCode != null &&
        context.read<StandardsCubit>().state.internetAvailable &&
        opMessage != null &&
        pack.operatorIDValid) {
      flag = Flag(
        alpha3CountryCode: countryCode,
        margin: const EdgeInsets.only(right: Sizes.standard / 2),
      );
    }
    final opIdText = pack.operatorIDSet
        ? opMessage!.operatorID.removeNonAlphanumeric()
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
            const AircraftDetailField(
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
                      style: TextStyle(
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
                  const Text(
                    'Location',
                    style: TextStyle(
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
                ? unitsSettingsCubit
                    .altitudeDefaultToCurrent(
                        UnitValue.meters(systemMessage.operatorAltitude!))
                    .toStringAsFixed(2)
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
                ? unitsSettingsCubit
                    .distanceDefaultToCurrent(
                        UnitValue.meters(systemMessage.areaRadius))
                    .toStringAsFixed(2)
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
                ? unitsSettingsCubit
                    .getAltitudeAsString(systemMessage.areaCeiling)
                : 'Unknown',
          ),
          AircraftDetailField(
            headlineText: 'Area Floor',
            fieldText: systemDataValid
                ? unitsSettingsCubit
                    .getAltitudeAsString(systemMessage.areaFloor)
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

  static String _getDistanceText(
      BuildContext context, SystemMessage? systemMessage) {
    final systemDataValid = systemMessage != null;
    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid &&
        systemDataValid &&
        locValid(systemMessage)) {
      final distanceFromMe = context
          .read<UnitsSettingsCubit>()
          .distanceDefaultToCurrent(calculateDistance(
            systemMessage.operatorLocation!.latitude,
            systemMessage.operatorLocation!.longitude,
            context.read<MapCubit>().state.userLocation.latitude,
            context.read<MapCubit>().state.userLocation.longitude,
          ));
      return distanceFromMe.toStringAsFixed(3);
    } else {
      return 'Unknown';
    }
  }
}
