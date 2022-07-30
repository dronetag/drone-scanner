import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';

class AircraftDetailField extends StatelessWidget {
  final String headlineText;
  final String? fieldText;
  final Widget? child;

  const AircraftDetailField({
    Key? key,
    required this.headlineText,
    this.fieldText,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headlineText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.droneScannerDetailFieldHeaderColor,
          ),
        ),
        if (child != null) child!,
        if (fieldText != null)
          Text(
            fieldText!,
            style: const TextStyle(
              color: AppColors.droneScannerDetailFieldColor,
            ),
          ),
      ],
    );
  }
}
