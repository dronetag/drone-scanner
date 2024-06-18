import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../bloc/units_settings_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/unit_value.dart';
import 'proximity_alerts_slider.dart';

class ProximityAlertDistanceField extends StatelessWidget {
  const ProximityAlertDistanceField({super.key});

  @override
  Widget build(BuildContext context) {
    final unitsSettingsCubit = context.read<UnitsSettingsCubit>();
    final distanceMeters = context.select<ProximityAlertsCubit, double>(
        (cubit) => cubit.state.proximityAlertDistance);

    final distanceUnitValue = unitsSettingsCubit
        .distanceDefaultToCurrent(UnitValue.meters(distanceMeters));

    final text = distanceUnitValue.toStringAsFixed(1);

    final controller = TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection:
            TextSelection.fromPosition(TextPosition(offset: text.length - 1)),
      ),
    );

    final minValue = unitsSettingsCubit.distanceDefaultToCurrent(
        UnitValue.meters(ProximityAlertsCubit.minProximityAlertDistance));
    final maxValue = unitsSettingsCubit.distanceDefaultToCurrent(
        UnitValue.meters(ProximityAlertsCubit.maxProximityAlertDistance));

    const defaultTextFieldWidth = 90.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proximity alerts distance'),
                  Text(
                    'Set horizontal distance threshold for proximity alerts',
                    textScaler: TextScaler.linear(0.8),
                    style: TextStyle(
                      color: AppColors.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: defaultTextFieldWidth,
              alignment: Alignment.center,
              child: TextFormField(
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(Sizes.standard),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.go,
                controller: controller,
                onEditingComplete: () {
                  final value = controller.text;

                  var newValue = double.parse(value.replaceAll(
                      unitsSettingsCubit.state.distanceSubUnit, ''));

                  if (newValue < minValue.value) {
                    newValue = minValue.value.toDouble();
                  } else if (newValue > maxValue.value) {
                    newValue = maxValue.value.toDouble();
                  }
                  _onChange(context, newValue);
                },
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProximityAlertsSlider(
              value: distanceUnitValue.value.round().toDouble(),
              onChangeEnd: (val) => _onChange(context, val),
              min: minValue.value.toDouble().floorToDouble(),
              max: maxValue.value.toDouble().ceilToDouble(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minValue.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.lightGray,
                  ),
                ),
                Text(
                  maxValue.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  // convert from current units to default meters that are saved in a cubit
  void _onChange(BuildContext context, double value) {
    final unitsSettingsCubit = context.read<UnitsSettingsCubit>();
    final unitValue =
        UnitValue(value: value, unit: unitsSettingsCubit.state.distanceSubUnit);

    context.read<ProximityAlertsCubit>().setProximityAlertsDistance(
        unitsSettingsCubit
            .distanceCurrentToDefault(unitValue)
            .value
            .toDouble());
  }
}
