import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

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
    return DropdownButton<String>(
      value: value,
      icon: const Icon(
        Icons.arrow_downward,
        color: AppColors.droneScannerDarkGray,
      ),
      elevation: 16,
      onChanged: valueChangedCallback,
      items: items
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
