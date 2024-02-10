import 'package:flutter/material.dart';

import '../../constants/sizes.dart';

class CustomTooltip extends StatelessWidget {
  final String message;
  final Color color;

  const CustomTooltip({super.key, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    final tooltipMargin =
        const EdgeInsets.symmetric(horizontal: Sizes.preferencesMargin);
    final tooltipPadding = const EdgeInsets.all(5);

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      padding: tooltipPadding,
      margin: tooltipMargin,
      message: message,
      child: Icon(
        Icons.help_outline,
        color: color,
        size: Sizes.textIconSize,
      ),
    );
  }
}
