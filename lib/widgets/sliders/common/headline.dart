import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class Headline extends StatelessWidget {
  final String text;
  final Widget? child;
  final Widget? leading;
  final Color? color;
  const Headline(
      {Key? key, required this.text, this.child, this.leading, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          if (leading != null) leading!,
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.lightGray,
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
