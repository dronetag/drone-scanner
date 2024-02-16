import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class IconCenterToLoc extends StatelessWidget {
  final VoidCallback onPressedCallback;

  const IconCenterToLoc({super.key, required this.onPressedCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.highlightBlue,
      ),
      height: Sizes.iconSize,
      width: Sizes.iconSize,
      child: IconButton(
        padding: const EdgeInsets.all(1.0),
        iconSize: 15,
        icon: const Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
        onPressed: onPressedCallback,
      ),
    );
  }
}
