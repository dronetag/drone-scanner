import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:vector_math/vector_math.dart';

import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
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
    double? distanceFromMe;
    late final String distanceText;
    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid &&
        loc != null &&
        locValid(loc)) {
      distanceFromMe = calculateDistance(
        loc.location!.latitude,
        loc.location!.longitude,
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
                    directionAsString(loc.direction!.toDouble()),
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
              fieldText: getAltitudeAsString(loc.height),
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
            fieldText: getAltitudeAsString(loc?.altitudePressure),
          ),
          AircraftDetailField(
            headlineText: 'Altitude Geod.',
            fieldText: getAltitudeAsString(loc?.altitudeGeodetic),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          if (loc != null)
            AircraftDetailField(
                headlineText: 'Horizontal Speed',
                fieldText: getSpeedHorAsString(loc.horizontalSpeed)),
          if (loc != null)
            AircraftDetailField(
              headlineText: 'Vertical Speed',
              fieldText: getSpeedVertAsString(loc.verticalSpeed),
            ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Horizontal Accuracy',
            fieldText: horizontalAccuracyToString(loc?.horizontalAccuracy),
          ),
          AircraftDetailField(
            headlineText: 'Vertical Accuracy',
            fieldText: verticalAccuracyToString(loc?.verticalAccuracy),
          ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Speed Accuracy',
            fieldText: speedAccuracyToString(loc?.speedAccuracy),
          ),
          AircraftDetailField(
            headlineText: 'Baro Accuracy',
            fieldText: verticalAccuracyToString(loc?.baroAltitudeAccuracy),
          ),
        ],
      ),
      AircraftDetailField(
        headlineText: 'Time Accuracy',
        fieldText: timeAccuracyToString(loc?.timestampAccuracy),
      ),
    ];
  }
}
