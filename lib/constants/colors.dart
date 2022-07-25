import 'package:flutter/material.dart';

class AppColors {
  static const dronetagBlue = Color(0xff00a0ff);
  static const dronetagAqua = Color(0xff3dc7e5);
  static const dronetagPurple = Color(0xff5a50c8);

  static const dronetagSlatePurple = Color(0xff5a64d2);
  static const dronetagNavy = Color(0xff2d3cb4);
  static const dronetagLightBlue = Color(0xff25abfc);
  static const veryDark = Color(0xff1d2023);
  static const dark = Color(0xff586065);
  static const gray = Color(0xff9fa8ad);
  static const lightGray = Color(0xffc7ccce);
  static const veryLightGray = Color(0xffe9ebec);

  static const highlight = Color(0xfff48a70);

  static const positive = Color(0xff8ec024);
  static const negative = Color(0xffc38c7f);
  static const stale = Color(0xfff1c060);
  static const warning = Color(0xffd9b146);

  static const warningLightBackground = Color(0xfff8f7f1);

  static const primaryGradientBegin = Color(0xff00a0ff);
  static const primaryGradientEnd = Color(0xff25abfc);

  static final primaryGlow = dronetagBlue.withOpacity(0.5);

  static const blueShadow = Color(0xa285b0d5);
  static const greenShadow = Color(0x8db0d837);
  static const purpleShadow = Color(0x955a64d2);
  static const grayShadow = Color(0x29000000);

  static const lightPurple = Color(0xffeff0fa);

  static const blueGradient = RadialGradient(
    colors: [
      AppColors.dronetagBlue,
      AppColors.dronetagLightBlue,
    ],
  );

  static const plannedTileBackgroundGradientBegin = lightPurple;
  static const plannedTileBackgroundGradientEnd = Colors.white;

  static const toolbarOpacity = 0.75;
  // drone scanner colors
  static const droneScannerDarkGray = Color.fromARGB(255, 22, 24, 25);
  static const droneScannerLightGray = Color.fromARGB(255, 189, 200, 201);
  static const droneScannerDetailHeaderColor = Color.fromARGB(255, 0, 38, 77);
  static const droneScannerDetailButtonsColor = Color.fromARGB(255, 0, 67, 126);
  static const droneScannerHighlightBlue = Color.fromARGB(255, 0, 132, 220);
  static const droneScannerPurple = Color.fromARGB(255, 120, 113, 235);
  static const droneScannerBlue = Color.fromARGB(255, 0, 104, 183);
  static const droneScannerRed = Color(0xFFA2483C);
  static const droneScannerGreen = Color(0xFF4D8439);
  static const droneScannerOrange = Color(0xFF957538);
  static const droneScannerDetailFieldHeaderColor = Color(0xFF636E71);
  static const droneScannerDetailFieldColor = Color(0xFF3B4345);
  static const droneScannerPreferencesButtonColor = Color(0xFF778487);
}
