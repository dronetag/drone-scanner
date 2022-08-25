import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenState {
  /// Size of the phone in UI Design , px
  num uiWidthPx;
  num uiHeightPx;

  double screenWidth;
  double screenHeight;
  double pixelRatio;
  double statusBarHeight;
  double bottomBarHeight;
  double textScaleFactor;

  /// allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  bool allowFontScaling;

  ScreenState({
    required this.uiWidthPx,
    required this.uiHeightPx,
    required this.screenWidth,
    required this.screenHeight,
    required this.pixelRatio,
    required this.statusBarHeight,
    required this.bottomBarHeight,
    required this.textScaleFactor,
    required this.allowFontScaling,
  });
}

class ScreenCubit extends Cubit<ScreenState> {
  static const defaultWidth = 1080.0;
  static const defaultHeight = 1920.0;

  ScreenCubit(
      {double width = defaultWidth,
      double height = defaultHeight,
      bool allowFontScaling = false})
      : super(
          ScreenState(
            uiWidthPx: width,
            uiHeightPx: height,
            allowFontScaling: allowFontScaling,
            pixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
            screenWidth: WidgetsBinding.instance.window.physicalSize.width,
            screenHeight: WidgetsBinding.instance.window.physicalSize.height,
            statusBarHeight: WidgetsBinding.instance.window.padding.top,
            bottomBarHeight: WidgetsBinding.instance.window.padding.bottom,
            textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
          ),
        );

  /// The number of font pixels for each logical pixel.
  double get textScaleFactor => state.textScaleFactor;

  /// The size of the media in logical pixels (e.g, the size of the screen).
  double get pixelRatio => state.pixelRatio;

  /// The horizontal extent of this size.
  double get screenWidthDp => state.screenWidth;

  ///The vertical extent of this size. dp
  double get screenHeightDp => state.screenHeight;

  /// The vertical extent of this size. px
  double get screenWidth => state.screenWidth * state.pixelRatio;

  /// The vertical extent of this size. px
  double get screenHeight => state.screenHeight * state.pixelRatio;

  /// The offset from the top
  double get statusBarHeight => state.statusBarHeight;

  /// The offset from the bottom.
  double get bottomBarHeight => state.bottomBarHeight;

  /// The ratio of the actual dp to the design draft px
  double get scaleWidth => state.screenWidth / state.uiWidthPx;

  double get scaleHeight => state.screenHeight / state.uiHeightPx;

  double get scaleText => scaleWidth;

  /// Adapted to the device width of the UI Design.
  /// Height can also be adapted according to this to ensure no deformation ,
  /// if you want a square
  num setWidth(num width) => width * scaleWidth;

  /// Highly adaptable to the device according to UI Design
  /// It is recommended to use this method to achieve a high degree of adaptation
  /// when it is found that one screen in the UI design
  /// does not match the current style effect, or if there is a difference in shape.
  num setHeight(num height) => height * scaleHeight;

  ///Font size adaptation method
  ///@param [fontSize] The size of the font on the UI design, in px.
  ///@param [allowFontScaling]
  num setSp(num fontSize, {bool? allowFontScalingSelf}) =>
      allowFontScalingSelf == null
          ? (state.allowFontScaling
              ? (fontSize * scaleText)
              : ((fontSize * scaleText) / state.textScaleFactor))
          : (allowFontScalingSelf
              ? (fontSize * scaleText)
              : ((fontSize * scaleText) / state.textScaleFactor));
}
