import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class PreferencesItem extends StatelessWidget {
  final Widget child;
  final String label;
  final String? description;

  const PreferencesItem({
    super.key,
    required this.child,
    required this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: description == null
              ? null
              : MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
              ),
              if (description != null)
                Text(
                  description!,
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
