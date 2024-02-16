import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../utils/utils.dart';

class AircraftCardCustomText extends StatelessWidget {
  final MessageContainer messagePack;

  const AircraftCardCustomText({
    super.key,
    required this.messagePack,
  });

  @override
  Widget build(BuildContext context) {
    final loc = messagePack.locationMessage;
    double? distanceFromMe;
    final preference = context.watch<SlidersCubit>().state.listFieldPreference;

    const emptyText = Text(
      'Unknown Location',
      textScaler: TextScaler.linear(0.9),
    );
    var text = 'Unknown Location';
    if (preference == ListFieldPreference.distance) {
      if (context.read<StandardsCubit>().state.locationEnabled &&
          loc != null &&
          messagePack.locationValid) {
        distanceFromMe = calculateDistance(
          loc.location!.latitude,
          loc.location!.longitude,
          context.read<MapCubit>().state.userLocation.latitude,
          context.read<MapCubit>().state.userLocation.longitude,
        );
        if (!context.read<StandardsCubit>().state.locationEnabled ||
            !context.read<MapCubit>().state.userLocationValid) {
          return emptyText;
        } else {
          text = '~${distanceFromMe.toStringAsFixed(2)} km away';
        }
      }
    } else if (preference == ListFieldPreference.location) {
      if (loc == null || !messagePack.locationValid) {
        return emptyText;
      } else {
        final latText = loc.location!.latitude.toStringAsFixed(6);
        final longText = loc.location!.longitude.toStringAsFixed(6);
        text = '$latText, $longText';
      }
    } else if (preference == ListFieldPreference.speed) {
      if (loc == null ||
          loc.horizontalSpeed == null ||
          loc.verticalSpeed == null) {
        return emptyText;
      } else {
        text = '${loc.horizontalSpeed} m/s, ${loc.verticalSpeed} m/s';
      }
    }

    return Text(
      text,
      textScaler: const TextScaler.linear(0.9),
    );
  }
}
