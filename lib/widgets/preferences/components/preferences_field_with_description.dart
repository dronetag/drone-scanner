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
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
              ),
              Text(
                description,
                textScaleFactor: 0.8,
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
