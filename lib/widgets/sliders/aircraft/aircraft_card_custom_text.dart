import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../bloc/units_settings_cubit.dart';
import '../../../models/unit_value.dart';
import '../../../utils/utils.dart';

class AircraftCardCustomText extends StatelessWidget {
  final MessageContainer messagePack;

  const AircraftCardCustomText({
    super.key,
    required this.messagePack,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _getText(context),
      textScaler: const TextScaler.linear(0.9),
    );
  }

  String _getText(BuildContext context) {
    final loc = messagePack.locationMessage;
    final preference = context.watch<SlidersCubit>().state.listFieldPreference;
    final standardsCubit = context.read<StandardsCubit>();
    final mapCubit = context.read<MapCubit>();
    final unitsSettingsCubit = context.read<UnitsSettingsCubit>();

    switch (preference) {
      case ListFieldPreference.distance:
        {
          if (standardsCubit.state.locationEnabled &&
              loc != null &&
              messagePack.locationValid) {
            final distanceFromMe = unitsSettingsCubit.distanceDefaultToCurrent(
              calculateDistance(
                loc.location!.latitude,
                loc.location!.longitude,
                mapCubit.state.userLocation.latitude,
                mapCubit.state.userLocation.longitude,
              ),
            );
            if (!standardsCubit.state.locationEnabled ||
                !mapCubit.state.userLocationValid) {
              return 'Unknown Distance';
            } else {
              return '~${distanceFromMe.toStringAsFixed(3)} away';
            }
          } else {
            return 'Unknown Distance';
          }
        }
      case ListFieldPreference.location:
        {
          if (loc == null || !messagePack.locationValid) {
            return 'Unknown Location';
          } else {
            final latText = loc.location!.latitude.toStringAsFixed(6);
            final longText = loc.location!.longitude.toStringAsFixed(6);
            return '$latText, $longText';
          }
        }
      case ListFieldPreference.speed:
        {
          if (loc == null ||
              loc.horizontalSpeed == null ||
              loc.verticalSpeed == null) {
            return 'Unknown Speed';
          } else {
            final horSpeedUnitValue = unitsSettingsCubit.speedDefaultToCurrent(
                UnitValue.metersPerSecond(loc.horizontalSpeed!));
            final vertSpeedUnitValue = unitsSettingsCubit.speedDefaultToCurrent(
                UnitValue.metersPerSecond(loc.verticalSpeed!));
            return '${horSpeedUnitValue.toStringAsFixed(1)}, '
                '${vertSpeedUnitValue.toStringAsFixed(1)}';
          }
        }
    }
  }
}
