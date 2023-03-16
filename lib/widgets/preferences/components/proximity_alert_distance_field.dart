import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import 'custom_spinbox.dart';
import 'text_with_slider_field.dart';

class ProximityAlertDistanceField extends StatelessWidget {
  const ProximityAlertDistanceField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance =
        context.read<ProximityAlertsCubit>().state.proximityAlertDistance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proximity alerts distance (m):'),
        Text(
          'Set the horizontal distance between your and other aircraft that fires alert.',
          textScaleFactor: 0.8,
          style: const TextStyle(
            color: AppColors.lightGray,
          ),
        ),
        TextWithSliderField(
          text: '${distance.round()} m',
          maxValue: ProximityAlertsCubit.maxProximityAlertDistance,
          minValue: ProximityAlertsCubit.minProximityAlertDistance,
          value: distance,
          onChange: (value) => context
              .read<ProximityAlertsCubit>()
              .setProximityAlertsDistance(value),
          onChangeEnd: (value) => context
              .read<ProximityAlertsCubit>()
              .setProximityAlertsDistance(value),
        ),
      ],
    );
  }
}
