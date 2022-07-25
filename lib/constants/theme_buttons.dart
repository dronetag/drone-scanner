import 'package:flutter/material.dart';

import 'colors.dart';
import 'sizes.dart';
import 'theme.dart';

class ButtonsAppTheme {
  static final borderRadius = BorderRadius.circular(99.0);
  static final defaultShape =
      RoundedRectangleBorder(borderRadius: borderRadius);
  static const defaultElevation = 0.0;

  static const buttonElevation = 5.0;
  static final buttonShadowColor = AppColors.gray.withOpacity(0.33);

  // -- Styles definitions

  /// Resolves [MaterialStateProperty] simply for [normal] and [disabled]
  /// states.
  /// FIXME: Not enough, resolve for the rest of states.
  static MaterialStateProperty<T> _resolveWithDisabled<T>(
          T normal, T disabled) =>
      MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.disabled) ? disabled : normal);

  static final baseStyle = ButtonStyle(
    shape: MaterialStateProperty.all(defaultShape),
    elevation: MaterialStateProperty.all(0.0),
  );

  /// Default button style (gray with white text, outlined when disabled)
  static final defaultStyle = baseStyle.copyWith(
    backgroundColor: _resolveWithDisabled(AppColors.gray, Colors.transparent),
    foregroundColor: _resolveWithDisabled(Colors.white, AppColors.lightGray),
    side: _resolveWithDisabled(BorderSide.none,
        const BorderSide(color: AppColors.lightGray, width: 2.0)),
  );

  /// Default text button style
  static final textButtonStyle = baseStyle.copyWith(
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor: _resolveWithDisabled(AppColors.dark, AppColors.lightGray),
  );

  /// Primary button style (primary color with glowy elevation)
  static final primaryStyle = defaultStyle.copyWith(
    backgroundColor:
        _resolveWithDisabled(AppColors.dronetagBlue, Colors.transparent),
    foregroundColor: _resolveWithDisabled(Colors.white, AppColors.lightGray),
    side: _resolveWithDisabled(BorderSide.none,
        const BorderSide(color: AppColors.lightGray, width: 2.0)),
    shadowColor: MaterialStateProperty.all(AppColors.primaryGlow),
    elevation: _resolveWithDisabled(8.0, 0),
  );

  /// Light button style (white color with dark text)
  static final lightStyle = defaultStyle.copyWith(
    backgroundColor: _resolveWithDisabled(Colors.white, Colors.transparent),
    foregroundColor: _resolveWithDisabled(AppColors.dark, AppColors.lightGray),
    overlayColor:
        MaterialStateProperty.all(AppColors.dronetagBlue.withOpacity(0.1)),
    elevation: _resolveWithDisabled(buttonElevation, 0),
    shadowColor: MaterialStateProperty.all(buttonShadowColor),
  );

  static final largeStyle = baseStyle.copyWith(
    minimumSize: MaterialStateProperty.all(
        const Size(Sizes.standard * 6, Sizes.standard * 6)),
  );

  static final withoutPaddingStyle = baseStyle.copyWith(
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(
        const Size(Sizes.standard * 6, Sizes.standard * 6)),
  );

  static final largeWithoutPaddingStyle = largeStyle.merge(withoutPaddingStyle);

  static final smallToolbarStyle = baseStyle.copyWith(
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(const Size.square(32.0)),
  );

  static final smallerStyle = baseStyle.copyWith(
    padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: Sizes.standard)),
    minimumSize: MaterialStateProperty.all(const Size.square(32.0)),
  );

  static final underlinedTextButtonStyle = textButtonStyle.copyWith(
      textStyle: MaterialStateProperty.all(
          AppTheme.lightTheme.textTheme.bodyText2!.copyWith(
        decoration: TextDecoration.underline,
      )),
      foregroundColor: MaterialStateProperty.all(
        AppColors.gray,
      ));

  static final negativeStyle = baseStyle.copyWith(
    backgroundColor: MaterialStateProperty.all(AppColors.negative),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );

  static final negativeWithoutPaddingStyle =
      negativeStyle.merge(withoutPaddingStyle);

  static final primaryTextStyle = textButtonStyle.copyWith(
    foregroundColor:
        _resolveWithDisabled(AppColors.dronetagBlue, AppColors.lightGray),
    textStyle: MaterialStateProperty.all(AppTheme
        .lightTheme.textTheme.bodyText1!
        .copyWith(fontWeight: FontWeight.w700)),
  );

  static final primaryDestructiveTextStyle = textButtonStyle.copyWith(
    foregroundColor:
        _resolveWithDisabled(AppColors.negative, AppColors.lightGray),
  );

  // -- Themes definitions

  static final navBarButtonTheme = TextButtonThemeData(
    style: textButtonStyle.copyWith(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      textStyle:
          MaterialStateProperty.all(AppTheme.lightTheme.textTheme.bodyText1),
      alignment: Alignment.centerRight,
    ),
  );
}
