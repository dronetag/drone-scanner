import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ShowcaseItem extends StatelessWidget {
  final String title;
  final String description;
  final GlobalKey showcaseKey;
  final Widget child;

  final double? opacity;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;

  const ShowcaseItem({
    Key? key,
    required this.title,
    required this.description,
    required this.showcaseKey,
    required this.child,
    this.opacity,
    this.backgroundColor,
    this.textColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      overlayOpacity: opacity ?? 0.75,
      overlayPadding: padding ?? EdgeInsets.zero,
      description: description,
      title: title,
      titleTextStyle: TextStyle(
        color: textColor ?? AppColors.blue,
        fontWeight: FontWeight.w600,
        fontSize: 23,
        height: 2,
      ),
      descTextStyle: TextStyle(
        color: textColor ?? Colors.black,
      ),
      contentPadding: const EdgeInsets.all(
        20,
      ),
      showcaseBackgroundColor: backgroundColor ?? Colors.white,
      child: child,
    );
  }
}
