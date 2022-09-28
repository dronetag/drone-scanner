import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
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
  static bool locValid(pigeon.LocationMessage? loc) {
    return loc != null &&
        loc.latitude != null &&
        loc.longitude != null &&
        loc.latitude != INV_LAT &&
        loc.longitude != INV_LON &&
        loc.latitude! <= MAX_LAT &&
        loc.longitude! <= MAX_LON &&
        loc.latitude! >= MIN_LAT &&
        loc.longitude! >= MIN_LON;
  }

  static List<Widget> buildLocationFields(
    BuildContext context,
    pigeon.LocationMessage? loc,
  ) {
    double? distanceFromMe;
    late final String distanceText;
    if (context.read<StandardsCubit>().state.locationEnabled &&
        loc != null &&
        locValid(loc)) {
      distanceFromMe = calculateDistance(
        loc.latitude!,
        loc.longitude!,
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
          if (loc != null && loc.status != null)
            AircraftDetailField(
              headlineText: 'Status',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    loc.status == pigeon.AircraftStatus.Airborne
                        ? Icons.flight_takeoff
                        : Icons.flight_land,
                    color: loc.status == pigeon.AircraftStatus.Airborne
                        ? AppColors.highlightBlue
                        : AppColors.dark,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    loc.status.toString().replaceAll('AircraftStatus.', ''),
                    style: TextStyle(
                      color: loc.status == pigeon.AircraftStatus.Airborne
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
                    loc.direction != INV_DIR)
                  Transform.rotate(
                    angle: radians(loc.direction!),
                    child: const Icon(
                      Icons.navigation_sharp,
                      size: 20,
                    ),
                  ),
                if (loc != null &&
                    loc.direction != null &&
                    loc.direction != INV_DIR)
                  const SizedBox(
                    width: 10,
                  ),
                Text(
                  directionAsString(loc?.direction),
                  style: const TextStyle(
                    color: AppColors.detailFieldColor,
                  ),
                ),
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
                  Text(
                    'Location',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.detailFieldHeaderColor,
                    ),
                  ),
                  Text(
                    loc != null && locValid(loc)
                        ? '${loc.latitude?.toStringAsFixed(4)}, '
                            '${loc.longitude?.toStringAsFixed(4)}'
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
                            loc.latitude!,
                            loc.longitude!,
                          );
                    }
                    context
                        .read<SlidersCubit>()
                        .panelController
                        .animatePanelToSnapPoint();
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
          if (loc != null && loc.heightType != null)
            AircraftDetailField(
              headlineText: 'Height Type',
              fieldText:
                  loc.heightType.toString().replaceAll('HeightType.', ''),
            ),
        ],
      ),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Altitude Press',
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
                fieldText: getSpeedHorAsString(loc.speedHorizontal)),
          if (loc != null)
            AircraftDetailField(
              headlineText: 'Vertical Speed',
              fieldText: getSpeedVertAsString(loc.speedVertical),
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
            fieldText: verticalAccuracyToString(loc?.baroAccuracy),
          ),
        ],
      ),
      AircraftDetailField(
        headlineText: 'Time Accuracy',
        fieldText: timeAccuracyToString(loc?.timeAccuracy),
      ),
    ];
  }
}
