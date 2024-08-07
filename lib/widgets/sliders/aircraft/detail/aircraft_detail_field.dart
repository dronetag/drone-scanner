import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../app/custom_tooltip.dart';

// field consists of headline, text element or child element
// if both are null. e.g. in case that no data are present for field,
// default text is used
class AircraftDetailField extends StatelessWidget {
  final String headlineText;
  final String? fieldText;
  final Widget? child;
  final String? tooltipMessage;

  const AircraftDetailField({
    super.key,
    required this.headlineText,
    this.fieldText,
    this.child,
    this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    final text = fieldText ?? '-';
    return Wrap(
      direction: Axis.vertical,
      children: [
        Wrap(
          direction: Axis.horizontal,
          spacing: Sizes.standard,
          children: [
            Text(
              headlineText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.detailFieldHeaderColor,
              ),
            ),
            if (tooltipMessage != null)
              CustomTooltip(
                message: tooltipMessage!,
                color: AppColors.detailFieldHeaderColor,
              )
          ],
        ),
        if (child != null) child!,
        if (child == null)
          Text(
            text,
            style: const TextStyle(
              color: AppColors.detailFieldColor,
            ),
          ),
      ],
    );
  }
}
