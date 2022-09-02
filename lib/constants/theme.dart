import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'sizes.dart';
import 'theme_buttons.dart';

class AppTheme {
  static const defaultElevation = 5.0;

  // Light Color Scheme
  static const lightColorScheme = ColorScheme(
    primary: AppColors.blue,
    primaryContainer: AppColors.highlightBlue,
    secondary: Color.fromARGB(255, 22, 24, 25),
    secondaryContainer: AppColors.highlightBlue,
    surface: Colors.white,
    background: Colors.white,
    error: AppColors.red,
    onPrimary: AppColors.dark,
    onSecondary: Colors.white,
    onSurface: AppColors.dark,
    onBackground: AppColors.dark,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  // Light UI Theme
  static final lightTheme = ThemeData(
    // Color scheme
    colorScheme: lightColorScheme,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      shadowColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Colors
    primaryColor: lightColorScheme.primary,
    backgroundColor: lightColorScheme.background,
    shadowColor: AppColors.darkGray.withOpacity(0.33),
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    disabledColor: AppColors.lightGray,

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
        color: AppColors.lightGray,
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
        color: AppColors.lightGray,
      ),
      overline: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: AppColors.lightGray,
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
      fillColor: AppColors.lightGray.withOpacity(0.25),
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
        color: AppColors.lightGray,
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGray),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
    ),

    // Sliders
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.lightGray,
      inactiveTrackColor: AppColors.lightGray,
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
    color: AppColors.lightGray,
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
