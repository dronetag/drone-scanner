import 'package:flutter/painting.dart';

class Sizes {
  static const standard = 8.0;
  static const half = standard * 0.5;
  static const double = standard * 2;

  static const spacing = standard * 1.5;
  static const screenSpacing = 10.0;

  static const cardPadding = 20.0;

  static const smallIcon = 16.0;
  static const mediumIcon = 48.0;
  static const largeIcon = 64.0;

  static const largeBorderRadius = Radius.circular(18.0);
  static const listItemLeading = 56.0;
  static const largeLeadingIcon = 42.0;

  static const largeSinglePrimaryButtonSize = Size.fromWidth(230);

  static const defaultContentPadding =
      EdgeInsets.fromLTRB(screenSpacing, 0.0, screenSpacing, double * 2.0);

  //static const S = 100;
  static const toolbarMinSizeRatioPortrait = 18;
  static const toolbarMinSizeRatioLandscape = 12;
  static const panelBorderRadius = 10.0;
  static const toolbarHeight = 50.0;
  static const iconSize = 25.0;
  static const textIconSize = 20.0;
  static const mapContentMargin = 10.0;
  static const showcaseMargin = 15.0;
}
