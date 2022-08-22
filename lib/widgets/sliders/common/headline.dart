import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class Headline extends StatelessWidget {
  final String text;
  final Widget? child;
  const Headline({Key? key, required this.text, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.lightGray,
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
