import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class PreferencesFieldWithDescription extends StatelessWidget {
  final Widget child;
  final String label;
  final String description;

  const PreferencesFieldWithDescription({
    Key? key,
    required this.child,
    required this.label,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
            ),
            Text(
              description,
              textScaleFactor: 0.8,
              style: TextStyle(
                color: AppColors.droneScannerLightGray,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
