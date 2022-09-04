import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../utils/utils.dart';

class AircraftCardCustomText extends StatelessWidget {
  final MessagePack messagePack;
  const AircraftCardCustomText({
    Key? key,
    required this.messagePack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = messagePack.locationMessage;
    double? distanceFromMe;
    final preference = context.watch<SlidersCubit>().state.listFieldPreference;

    const emptyText = Text(
      'Unknown Location',
      textScaleFactor: 0.9,
    );
    var text = 'Unknown Location';
    if (preference == ListFieldPreference.distance) {
      if (context.read<StandardsCubit>().state.locationEnabled &&
          loc != null &&
          loc.latitude != null &&
          loc.longitude != null) {
        distanceFromMe = calculateDistance(
          loc.latitude!,
          loc.longitude!,
          context.read<MapCubit>().state.userLocation.latitude,
          context.read<MapCubit>().state.userLocation.longitude,
        );
        if (!context.read<StandardsCubit>().state.locationEnabled) {
          return emptyText;
        } else {
          text = '~${distanceFromMe.toStringAsFixed(2)} km away';
        }
      }
    } else if (preference == ListFieldPreference.location) {
      if (loc == null || loc.latitude == null || loc.longitude == null) {
        return emptyText;
      } else {
        final latText = loc.latitude!.toStringAsFixed(6);
        final longText = loc.longitude!.toStringAsFixed(6);
        text = '$latText, $longText';
      }
    } else if (preference == ListFieldPreference.speed) {
      if (loc == null ||
          loc.speedHorizontal == null ||
          loc.speedVertical == null) {
        return emptyText;
      } else {
        text = '${loc.speedHorizontal} m/s, ${loc.speedVertical} m/s';
      }
    }

    return Text(
      text,
      textScaleFactor: 0.9,
    );
  }
}
