import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/screen_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ShowcaseWidget extends StatelessWidget {
  final String heading;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? overlayPadding;
  final VoidCallback? nextCallback;
  final VoidCallback? skipCallback;

  const ShowcaseWidget({
    super.key,
    required this.heading,
    required this.text,
    this.nextCallback,
    this.skipCallback,
    this.backgroundColor,
    this.textColor,
    this.overlayPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor ?? Colors.white,
      ),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.showcaseMargin,
              vertical: Sizes.showcaseMargin / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: textColor ?? AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 21,
                    height: 2,
                  ),
                ),
                SizedBox(
                  height: 15 * context.read<ScreenCubit>().scaleHeight,
                ),
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: textColor ?? Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (nextCallback != null && skipCallback != null)
            const SizedBox(
              height: 20,
            ),
          if (nextCallback != null)
            ElevatedButton(
              onPressed: nextCallback,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  AppColors.blue,
                ),
              ),
              child: const Text('Start Tutorial'),
            ),
          const SizedBox(
            width: 10,
          ),
          if (skipCallback != null)
            ElevatedButton(
              onPressed: skipCallback,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
