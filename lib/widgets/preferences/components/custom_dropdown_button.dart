import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class CustomDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) valueChangedCallback;

  const CustomDropdownButton({
    Key? key,
    required this.value,
    required this.items,
    required this.valueChangedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        alignment: Alignment.centerRight,
        value: value,
        isDense: true,
        icon: const RotatedBox(
          quarterTurns: 3,
          child: Icon(
            Icons.chevron_left,
            color: AppColors.darkGray,
            size: Sizes.iconSize,
          ),
        ),
        elevation: 16,
        onChanged: valueChangedCallback,
        items: items
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  textScaler: const TextScaler.linear(0.9),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
