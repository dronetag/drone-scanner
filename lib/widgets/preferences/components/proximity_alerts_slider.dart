import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class ProximityAlertsSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;

  final void Function(double) onChangeEnd;

  const ProximityAlertsSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChangeEnd,
  });

  @override
  State<ProximityAlertsSlider> createState() => _ProximityAlertsSliderState();
}

class _ProximityAlertsSliderState extends State<ProximityAlertsSlider> {
  late double value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackShape: _CustomTrackShape(),
      ),
      child: Slider(
        value: value,
        onChanged: (val) => setState(() {
          value = val;
        }),
        onChangeEnd: (val) => widget.onChangeEnd(val),
        min: widget.min,
        max: widget.max,
        thumbColor: AppColors.preferencesButtonColor,
        activeColor: AppColors.lightGray,
        inactiveColor: AppColors.lightGray,
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const thumbSize = 10;
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx + thumbSize;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width - thumbSize * 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
