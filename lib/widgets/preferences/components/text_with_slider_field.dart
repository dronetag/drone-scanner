import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const defaultTextFieldWidth = 70.0;

/// Widget which contains [TextFormField] widget on the left side of the row
/// and [Slider] widget on the right side of the row.
/// User can update TextFormField value manualy and value of Slider
/// is updating automaticly.
/// User can slide on the Slider and updates user value on TextFormField.

class TextWithSliderField extends StatelessWidget {
  final String text;
  final double? textFieldWidth;
  final double minValue;
  final double maxValue;
  final double value;
  final Function(double) onChange;
  final Function(double) onChangeEnd;

  TextWithSliderField({
    required this.text,
    this.textFieldWidth,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChange,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: text,
      ),
    );

    return Row(
      children: [
        Container(
          width: textFieldWidth ?? defaultTextFieldWidth,
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
              onChangeEnd(newValue);
            },
          ),
        ),
        Flexible(
          child: Slider(
            value: value,
            onChanged: onChange,
            onChangeEnd: onChangeEnd,
            min: minValue,
            max: maxValue,
          ),
        ),
      ],
    );
  }
}
