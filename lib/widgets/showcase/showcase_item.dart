import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import 'showcase_widget.dart';

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
    super.key,
    required this.title,
    required this.description,
    required this.showcaseKey,
    required this.child,
    this.opacity,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: showcaseKey,
      width: MediaQuery.of(context).size.width - 20,
      height: 0,
      overlayOpacity: opacity ?? 0.75,
      targetPadding: padding ?? EdgeInsets.zero,
      container: ShowcaseWidget(
        heading: title,
        text: description,
        overlayPadding: padding ?? EdgeInsets.zero,
        textColor: textColor,
        backgroundColor: backgroundColor ?? Colors.white,
      ),
      child: child,
    );
  }
}
