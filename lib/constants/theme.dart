import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'sizes.dart';
import 'theme_buttons.dart';

class AppTheme {
  static const defaultElevation = 5.0;

  // Light Color Scheme
  static const lightColorScheme = ColorScheme(
    primary: AppColors.dronetagBlue,
    primaryContainer: AppColors.dronetagNavy,
    secondary: Color.fromARGB(255, 22, 24, 25),
    secondaryContainer: AppColors.dronetagNavy,
    surface: Colors.white,
    background: Colors.white,
    error: AppColors.negative,
    onPrimary: AppColors.dark,
    onSecondary: Colors.white,
    onSurface: AppColors.dark,
    onBackground: AppColors.dark,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  static final defaultBarrierColor = AppColors.gray.withOpacity(0.5);

  // Dark Color Scheme
  static const darkColorScheme = ColorScheme(
    background: Colors.white,
    brightness: Brightness.dark,
    error: AppColors.negative,
    onBackground: Colors.white,
    onError: AppColors.negative,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    primary: AppColors.dronetagBlue,
    primaryContainer: AppColors.dronetagNavy,
    secondary: AppColors.gray,
    secondaryContainer: AppColors.dronetagNavy,
    surface: AppColors.veryDark,
  );

  // Light UI Theme
  static final lightTheme = ThemeData(
    // Color scheme
    colorScheme: lightColorScheme,
    brightness: Brightness.light,

    // Colors
    primaryColor: lightColorScheme.primary,
    backgroundColor: lightColorScheme.background,
    shadowColor: AppColors.gray.withOpacity(0.33),
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    disabledColor: AppColors.veryLightGray,

    // Typography
    fontFamily: 'TitilliumWeb',
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      headline2: TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      headline3: TextStyle(
        fontSize: 24,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: AppColors.dark,
      ),
      headline4: TextStyle(
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      headline5: TextStyle(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
      headline6: TextStyle(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
      subtitle1: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.normal,
        color: AppColors.dark,
      ),
      subtitle2: TextStyle(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: AppColors.gray,
      ),
      button: TextStyle(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      bodyText2: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.normal,
        color: AppColors.dark,
      ),
      caption: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: AppColors.gray,
      ),
      overline: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: AppColors.gray,
        letterSpacing: 1.05,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonsAppTheme.defaultStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonsAppTheme.textButtonStyle,
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.veryLightGray.withOpacity(0.25),
      labelStyle: const TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.normal,
        color: AppColors.dark,
      ),
      helperMaxLines: 5,
      helperStyle: const TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.normal,
        color: AppColors.gray,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Sizes.double,
        vertical: Sizes.standard,
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGray),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray),
      ),
    ),

    // Sliders
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.gray,
      inactiveTrackColor: AppColors.gray,
      thumbColor: Colors.white,
      disabledActiveTrackColor: AppColors.lightGray,
      disabledInactiveTrackColor: AppColors.lightGray,
      disabledThumbColor: AppColors.lightGray,
      trackHeight: 3.0,
    ),

    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.standard),
      ),
      elevation: defaultElevation,
      margin: const EdgeInsets.symmetric(vertical: Sizes.half),
    ),
  );

  static final darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    primaryColor: darkColorScheme.primary,
    backgroundColor: darkColorScheme.background,
    cardColor: AppColors.veryDark,
    shadowColor: Colors.black,
    canvasColor: AppColors.veryDark,
    scaffoldBackgroundColor: AppColors.veryDark,
    disabledColor: AppColors.veryLightGray,
  );

  static SystemUiOverlayStyle getDefaultSystemUIOverlay(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).canvasColor,
      systemNavigationBarIconBrightness:
          isLight ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
    );
  }

  // Alternative typography
  static const monospacedTextStyle = TextStyle(
    fontFamily: 'RobotoMono',
  );
  static const monospacedSubtitleTextStyle = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 12.0,
    color: AppColors.gray,
  );

  static final captionLinkTextStyle = lightTheme.textTheme.caption!.copyWith(
    decoration: TextDecoration.underline,
  );

  // Alternative input decoration
  static const tinyInputStyle = InputDecoration(
    isDense: true,
    contentPadding:
        EdgeInsets.symmetric(horizontal: Sizes.standard, vertical: Sizes.half),
  );
}
