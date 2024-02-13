import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '../../../constants/colors.dart';

class CustomSpinBox extends StatelessWidget {
  final ValueSetter<double> valueSetter;
  final double maxVal;
  final double minVal;
  final double step;
  final double value;

  const CustomSpinBox({
    Key? key,
    required this.maxVal,
    required this.minVal,
    required this.step,
    required this.value,
    required this.valueSetter,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            if (value - step >= minVal) {
              valueSetter(value - step);
            }
          },
          icon: const Icon(
            Icons.remove,
            color: AppColors.preferencesButtonColor,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Align(
          child: SizedBox(
            width: width / 6,
            child: SpinBox(
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              min: minVal,
              max: maxVal,
              value: value,
              step: step,
              showButtons: false,
              onChanged: (v) {
                if (v < minVal || v > maxVal) {
                  return;
                }
                valueSetter(v);
              },
              decoration: const InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () {
            if (value + step <= maxVal) {
              valueSetter(value + step);
            }
          },
          icon: const Icon(
            Icons.add,
            color: AppColors.preferencesButtonColor,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
