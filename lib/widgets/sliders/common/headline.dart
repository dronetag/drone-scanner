import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class Headline extends StatelessWidget {
  final String text;
  final Widget? child;
  final Widget? leading;
  final Color? color;
  final double? fontSize;
  const Headline({
    Key? key,
    required this.text,
    this.child,
    this.leading,
    this.color,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          if (leading != null)
            Padding(
              padding: const EdgeInsets.only(right: Sizes.standard / 2),
              child: leading!,
            ),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.lightGray,
              fontSize: fontSize,
            ),
          ),
          if (child != null)
            const SizedBox(
              width: 5,
            ),
          if (child != null) child!,
          const SizedBox(
            width: 20,
          ),
          const Expanded(
            child: Divider(
              thickness: 2,
              color: AppColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }
}
