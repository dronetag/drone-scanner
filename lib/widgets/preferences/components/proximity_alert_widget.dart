import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/aircraft_metadata_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../bloc/units_settings_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/unit_value.dart';

class ProximityAlertWidget extends StatelessWidget {
  final DroneNearbyAlert alert;

  const ProximityAlertWidget({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final aircraftCubit = context.read<AircraftCubit>();
    final aircraftMetadataCubit = context.read<AircraftMetadataCubit>();
    final droneMac = aircraftCubit.findByUasID(alert.uasId)?.macAddress;
    final distanceText = context
        .read<UnitsSettingsCubit>()
        .distanceDefaultToCurrent(UnitValue.meters(alert.distance))
        .toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.pink),
        borderRadius: BorderRadius.circular(Sizes.panelBorderRadius),
      ),
      padding: const EdgeInsets.all(
        Sizes.mapContentMargin / 2,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: Sizes.iconPadding),
                child: Icon(
                  Icons.location_searching,
                  size: Sizes.textIconSize,
                ),
              ),
              // show label if exists
              Text(
                aircraftMetadataCubit.state.aircraftLabels.containsKey(droneMac)
                    ? aircraftMetadataCubit.state.aircraftLabels[droneMac]!
                    : alert.uasId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                '~$distanceText',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
