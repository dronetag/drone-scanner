import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class PreferencesFieldWithDescription extends StatelessWidget {
  final Widget child;
  final String label;
  final String description;

  const PreferencesFieldWithDescription({
    super.key,
    required this.child,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: isLandscape
              ? MediaQuery.of(context).size.width / 16 * 5
              : MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
              ),
              Text(
                description,
                textScaler: const TextScaler.linear(0.8),
                style: const TextStyle(
                  color: AppColors.lightGray,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
