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
  static final buttonShadowColor = AppColors.lightGray.withOpacity(0.33);

  // -- Styles definitions

  /// Resolves [WidgetStateProperty] simply for [normal] and [disabled]
  /// states.
  /// FIXME: Not enough, resolve for the rest of states.
  static WidgetStateProperty<T> _resolveWithDisabled<T>(
    T normal,
    T disabled,
  ) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? disabled : normal,
      );

  static final baseStyle = ButtonStyle(
    shape: WidgetStateProperty.all(defaultShape),
    elevation: WidgetStateProperty.all(0.0),
  );

  /// Default button style (gray with white text, outlined when disabled)
  static final defaultStyle = baseStyle.copyWith(
    backgroundColor:
        _resolveWithDisabled(AppColors.lightGray, Colors.transparent),
    foregroundColor: _resolveWithDisabled(Colors.white, AppColors.lightGray),
    side: _resolveWithDisabled(
      BorderSide.none,
      const BorderSide(color: AppColors.lightGray, width: 2.0),
    ),
  );

  /// Default text button style
  static final textButtonStyle = baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
    foregroundColor: _resolveWithDisabled(AppColors.dark, AppColors.lightGray),
  );

  /// Primary button style (primary color with glowy elevation)
  static final primaryStyle = defaultStyle.copyWith(
    backgroundColor: _resolveWithDisabled(AppColors.blue, Colors.transparent),
    foregroundColor: _resolveWithDisabled(Colors.white, AppColors.lightGray),
    side: _resolveWithDisabled(
      BorderSide.none,
      const BorderSide(color: AppColors.lightGray, width: 2.0),
    ),
    shadowColor: WidgetStateProperty.all(AppColors.lightGray),
    elevation: _resolveWithDisabled(8.0, 0),
  );

  /// Light button style (white color with dark text)
  static final lightStyle = defaultStyle.copyWith(
    backgroundColor: _resolveWithDisabled(Colors.white, Colors.transparent),
    foregroundColor: _resolveWithDisabled(AppColors.dark, AppColors.lightGray),
    overlayColor: WidgetStateProperty.all(AppColors.blue.withOpacity(0.1)),
    elevation: _resolveWithDisabled(buttonElevation, 0),
    shadowColor: WidgetStateProperty.all(AppColors.lightGray),
  );

  static final largeStyle = baseStyle.copyWith(
    minimumSize: WidgetStateProperty.all(
      const Size(Sizes.standard * 6, Sizes.standard * 6),
    ),
  );

  static final withoutPaddingStyle = baseStyle.copyWith(
    padding: WidgetStateProperty.all(EdgeInsets.zero),
    minimumSize: WidgetStateProperty.all(
      const Size(Sizes.standard * 6, Sizes.standard * 6),
    ),
  );

  static final largeWithoutPaddingStyle = largeStyle.merge(withoutPaddingStyle);

  static final smallToolbarStyle = baseStyle.copyWith(
    padding: WidgetStateProperty.all(EdgeInsets.zero),
    minimumSize: WidgetStateProperty.all(const Size.square(32.0)),
  );

  static final smallerStyle = baseStyle.copyWith(
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: Sizes.standard),
    ),
    minimumSize: WidgetStateProperty.all(const Size.square(32.0)),
  );

  static final underlinedTextButtonStyle = textButtonStyle.copyWith(
    textStyle: WidgetStateProperty.all(
      AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
        decoration: TextDecoration.underline,
      ),
    ),
    foregroundColor: WidgetStateProperty.all(
      AppColors.lightGray,
    ),
  );

  static final negativeStyle = baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.red),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );

  static final negativeWithoutPaddingStyle =
      negativeStyle.merge(withoutPaddingStyle);

  static final primaryTextStyle = textButtonStyle.copyWith(
    foregroundColor: _resolveWithDisabled(AppColors.blue, AppColors.lightGray),
    textStyle: WidgetStateProperty.all(
      AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static final primaryDestructiveTextStyle = textButtonStyle.copyWith(
    foregroundColor: _resolveWithDisabled(
      AppColors.red,
      AppColors.lightGray,
    ),
  );

  // -- Themes definitions

  static final navBarButtonTheme = TextButtonThemeData(
    style: textButtonStyle.copyWith(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      textStyle:
          WidgetStateProperty.all(AppTheme.lightTheme.textTheme.bodyLarge),
      alignment: Alignment.centerRight,
    ),
  );
}
