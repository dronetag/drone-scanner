import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:vector_math/vector_math.dart';

import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
import '../../../../bloc/units_settings_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../utils/utils.dart';
import '../../common/headline.dart';
import '../../common/icon_center_to_loc.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';

class LocationFields {
  static bool locValid(LocationMessage? loc) {
    return loc != null &&
        loc.location?.latitude != null &&
        loc.location?.longitude != null &&
        loc.location!.latitude != INV_LAT &&
        loc.location!.longitude != INV_LON &&
        loc.location!.latitude <= MAX_LAT &&
        loc.location!.longitude <= MAX_LON &&
        loc.location!.latitude >= MIN_LAT &&
        loc.location!.longitude >= MIN_LON;
  }

  static List<Widget> buildLocationFields(
    BuildContext context,
    LocationMessage? loc,
  ) {
    final unitsSettingsCubit = context.read<UnitsSettingsCubit>();
    final distanceText = _getDistanceText(context, loc);

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return [
      const Headline(text: 'LOCATION'),
      if (isLandscape) const SizedBox(),
      AircraftDetailRow(
        children: [
          if (loc != null)
            AircraftDetailField(
              headlineText: 'Status',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (loc.status != OperationalStatus.none) ...[
                    Icon(
                      loc.status == OperationalStatus.airborne
                          ? Icons.flight_takeoff
                          : Icons.flight_land,
                      color: loc.status == OperationalStatus.airborne
                          ? AppColors.highlightBlue
                          : AppColors.dark,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                  Text(
                    loc.status.asString() ?? 'Unknown',
                    style: TextStyle(
                      color: loc.status == OperationalStatus.airborne
                          ? AppColors.highlightBlue
                          : AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
            ),
          AircraftDetailField(
            headlineText: 'Heading Track',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loc != null &&
                    loc.direction != null &&
                    loc.direction != INV_DIR) ...[
                  Transform.rotate(
                    angle: radians(loc.direction!.toDouble()),
                    child: const Icon(
                      Icons.navigation_sharp,
                      size: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    unitsSettingsCubit
                        .getDirectionAsString(loc.direction!.toDouble()),
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Distance from me',
            fieldText: distanceText,
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.detailFieldHeaderColor,
                    ),
                  ),
                  Text(
                    loc != null && locValid(loc)
                        ? '${loc.location!.latitude.toStringAsFixed(4)}, '
                            '${loc.location!.longitude.toStringAsFixed(4)}'
                        : 'Unknown',
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
              if (locValid(loc))
                IconCenterToLoc(
                  onPressedCallback: () {
                    if (loc != null && locValid(loc)) {
                      context.read<MapCubit>().centerToLocDouble(
                            loc.location!.latitude,
                            loc.location!.longitude,
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
          if (loc != null && loc.height != null)
            AircraftDetailField(
              headlineText: 'Height',
              fieldText: unitsSettingsCubit.getAltitudeAsString(loc.height),
            ),
          if (loc != null)
            AircraftDetailField(
              headlineText: 'Height Type',
              fieldText: loc.heightType.asString(),
            ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Altitude Press.',
            fieldText:
                unitsSettingsCubit.getAltitudeAsString(loc?.altitudePressure),
          ),
          AircraftDetailField(
            headlineText: 'Altitude Geod.',
            fieldText:
                unitsSettingsCubit.getAltitudeAsString(loc?.altitudeGeodetic),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          if (loc != null)
            AircraftDetailField(
                headlineText: 'Horizontal Speed',
                fieldText: unitsSettingsCubit
                    .getHorizontalSpeedAsString(loc.horizontalSpeed)),
          if (loc != null)
            AircraftDetailField(
              headlineText: 'Vertical Speed',
              fieldText: unitsSettingsCubit
                  .getVerticalSpeedAsString(loc.verticalSpeed),
            ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Horizontal Accuracy',
            fieldText: unitsSettingsCubit
                .getHorizontalAccuracyAsString(loc?.horizontalAccuracy),
          ),
          AircraftDetailField(
            headlineText: 'Vertical Accuracy',
            fieldText: unitsSettingsCubit
                .getVerticalAccuracyAsString(loc?.verticalAccuracy),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Speed Accuracy',
            fieldText:
                unitsSettingsCubit.getSpeedAccuracyAsString(loc?.speedAccuracy),
          ),
          AircraftDetailField(
            headlineText: 'Baro Accuracy',
            fieldText: unitsSettingsCubit
                .getVerticalAccuracyAsString(loc?.baroAltitudeAccuracy),
          ),
        ],
      ),
      AircraftDetailField(
        headlineText: 'Time Accuracy',
        fieldText:
            unitsSettingsCubit.getTimeAccuracyAsString(loc?.timestampAccuracy),
      ),
    ];
  }

  static String _getDistanceText(
    BuildContext context,
    LocationMessage? loc,
  ) {
    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid &&
        loc != null &&
        locValid(loc)) {
      final distanceFromMe =
          context.read<UnitsSettingsCubit>().distanceDefaultToCurrent(
                calculateDistanceInKm(
                  loc.location!.latitude,
                  loc.location!.longitude,
                  context.read<MapCubit>().state.userLocation.latitude,
                  context.read<MapCubit>().state.userLocation.longitude,
                ),
              );
      return distanceFromMe.toStringAsFixed(3);
    } else {
      return 'Unknown';
    }
  }
}
