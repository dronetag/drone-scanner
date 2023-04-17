import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';

class ProximityAlertDistanceField extends StatelessWidget {
  const ProximityAlertDistanceField({Key? key}) : super(key: key);

  void _onChange(BuildContext context, double value) =>
      context.read<ProximityAlertsCubit>().setProximityAlertsDistance(value);

  void _onChangeEnd(BuildContext context, double value) =>
      context.read<ProximityAlertsCubit>().setProximityAlertsDistance(value);

  @override
  Widget build(BuildContext context) {
    final distance =
        context.read<ProximityAlertsCubit>().state.proximityAlertDistance;
    final _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: '${distance.round()}m',
      ),
    );
    final minValue = ProximityAlertsCubit.minProximityAlertDistance;
    final maxValue = ProximityAlertsCubit.maxProximityAlertDistance;
    const defaultTextFieldWidth = 70.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proximity alerts distance:'),
        Row(
          children: [
            Flexible(
              child: Text(
                'Set horizontal distance threshold for proximity alerts',
                textScaleFactor: 0.8,
                style: const TextStyle(
                  color: AppColors.lightGray,
                ),
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
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5.0), isDense: true),
                keyboardType: TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.go,
                controller: _controller,
                onTap: () => _controller.selection = TextSelection(
                    baseOffset: 0, extentOffset: _controller.value.text.length),
                onFieldSubmitted: (value) {
                  var newValue = double.parse(value);
                  if (newValue < minValue) {
                    newValue = minValue;
                  } else if (newValue > maxValue) {
                    newValue = maxValue;
                  }
                  _onChangeEnd(context, newValue);
                },
              ),
            ),
          ],
        ),
        Slider(
          value: distance,
          onChanged: (val) => _onChange(context, val),
          onChangeEnd: (val) => _onChangeEnd(context, val),
          min: minValue,
          max: maxValue,
          thumbColor: AppColors.darkGray,
          activeColor: AppColors.lightGray,
          inactiveColor: AppColors.lightGray,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${minValue}m',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.lightGray,
              ),
            ),
            Text(
              '${maxValue}m',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.lightGray,
              ),
            ),
          ],
        )
      ],
    );
  }
}
