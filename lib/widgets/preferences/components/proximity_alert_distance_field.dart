import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

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
    final text = '${distance.round()}m';
    final _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection:
            TextSelection.fromPosition(TextPosition(offset: text.length - 1)),
      ),
    );
    final minValue = ProximityAlertsCubit.minProximityAlertDistance;
    final maxValue = ProximityAlertsCubit.maxProximityAlertDistance;
    const defaultTextFieldWidth = 90.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proximity alerts distance:'),
                  Text(
                    'Set horizontal distance threshold for proximity alerts',
                    textScaleFactor: 0.8,
                    style: const TextStyle(
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
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(Sizes.standard),
                  isDense: true,
                ),
                keyboardType: TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.go,
                controller: _controller,
                onFieldSubmitted: (value) {
                  var newValue = double.parse(value.replaceAll('m', ''));
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
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SliderTheme(
              data: SliderThemeData(
                // here
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                value: distance,
                onChanged: (val) => _onChange(context, val),
                onChangeEnd: (val) => _onChangeEnd(context, val),
                min: minValue,
                max: maxValue,
                thumbColor: AppColors.preferencesButtonColor,
                activeColor: AppColors.lightGray,
                inactiveColor: AppColors.lightGray,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${minValue.toStringAsFixed(0)}m',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.lightGray,
                  ),
                ),
                Text(
                  '${(maxValue / 1000).toStringAsFixed(0)}km',
                  style: TextStyle(
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
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final thumbSize = 10;
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx + thumbSize;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width - thumbSize * 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
