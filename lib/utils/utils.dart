import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:sprintf/sprintf.dart';

import '../extensions/string_extensions.dart';

T swapSign<T extends num>(T value) {
  return value.isNegative ? value.abs() as T : value * -1 as T;
}

double toPrecision(double value, [int precision = 3]) {
  return double.parse(value.toStringAsFixed(precision));
}

double calcHeaderHeight(BuildContext context) {
  final height = MediaQuery.of(context).size.height;
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  return isLandscape ? height / 5 : height / 9;
}

// calculates distance in km
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  const c = math.cos;
  final a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * math.asin(math.sqrt(a));
}

String getSourceText(MessageSource source) {
  var sourceText = '';
  if (source == MessageSource.BluetoothLegacy) {
    sourceText = 'BT 4 Legacy';
  } else if (source == MessageSource.BluetoothLongRange) {
    sourceText = 'BT 5 Extended';
  } else if (source == MessageSource.WifiBeacon) {
    sourceText = 'Wi-Fi Beacon';
  } else if (source == MessageSource.WifiNan) {
    sourceText = 'Wi-Fi NaN';
  }
  return sourceText;
}

String getSourceShortcut(MessageSource source) {
  var sourceText = '';
  if (source == MessageSource.BluetoothLegacy) {
    sourceText = '4';
  } else if (source == MessageSource.BluetoothLongRange) {
    sourceText = '5';
  } else if (source == MessageSource.WifiBeacon) {
    sourceText = 'B';
  } else if (source == MessageSource.WifiNan) {
    sourceText = 'N';
  }
  return sourceText;
}

String horizontalAccuracyToString(HorizontalAccuracy? acc) {
  if (acc == null) return 'Unknown';
  switch (acc) {
    case HorizontalAccuracy.unknown:
      return 'Unknown';
    case HorizontalAccuracy.meters_30:
      return '< 30 m';
    case HorizontalAccuracy.meters_1:
      return '< 1 m';
    case HorizontalAccuracy.meters_10:
      return '< 10 m';
    case HorizontalAccuracy.meters_926:
      return '< 926 m';
    case HorizontalAccuracy.meters_555_6:
      return '< 555.6 km';
    case HorizontalAccuracy.meters_185_2:
      return '< 185.2 km';
    case HorizontalAccuracy.meters_92_6:
      return '< 92.6 m';
    case HorizontalAccuracy.meters_3:
      return '< 3 m';
    case HorizontalAccuracy.kilometers_18_52:
      return '< 18.52 km';
    case HorizontalAccuracy.kilometers_7_408:
      return '< 7.408 km';
    case HorizontalAccuracy.kilometers_3_704:
      return '< 3.704 km';
    case HorizontalAccuracy.kilometers_1_852:
      return '< 1.852 km';
  }
}

String verticalAccuracyToString(VerticalAccuracy? acc) {
  if (acc == null) return 'Unknown';
  switch (acc) {
    case VerticalAccuracy.meters_150:
      return '< 150 m';
    case VerticalAccuracy.meters_45:
      return '< 45 m';
    case VerticalAccuracy.meters_25:
      return '< 25 m';
    case VerticalAccuracy.meters_10:
      return '< 10 m';
    case VerticalAccuracy.meters_3:
      return '< 3 m';
    case VerticalAccuracy.meters_1:
      return '< 1 m';
    default:
      return 'Unknown';
  }
}

String speedAccuracyToString(SpeedAccuracy? acc) {
  if (acc == null) return 'Unknown';
  switch (acc) {
    case SpeedAccuracy.meterPerSecond_10:
      return '< 10 m/s';
    case SpeedAccuracy.meterPerSecond_3:
      return '< 3 m/s';
    case SpeedAccuracy.meterPerSecond_1:
      return '< 1 m/s';
    case SpeedAccuracy.meterPerSecond_0_3:
      return '< 0.3 m/s';
    default:
      return 'Unknown';
  }
}

String timeAccuracyToString(Duration? acc) {
  if (acc == null) return 'Unknown';
  if (acc.inMilliseconds == 0) {
    return 'Unknown';
  } else {
    return sprintf('<= %1.1f s', [acc.inMilliseconds / 1000.0]);
  }
}

String directionAsString(double? direction) {
  if (direction == null) return 'Unknown';
  if (direction != INV_DIR) {
    return sprintf('%3.0f °', [direction]);
  } else {
    return 'Unknown';
  }
}

String getAltitudeAsString(double? altitude) {
  if (altitude == null || altitude == INV_ALT) return 'Unknown';
  return sprintf('%3.1f m', [altitude]);
}

String getSpeedVertAsString(double? speed) {
  if (speed == null || speed == INV_SPEED_V) return 'Unknown';
  return sprintf('%3.2f m/s', [speed]);
}

String getSpeedHorAsString(double? speed) {
  if (speed == null || speed == INV_SPEED_H) return 'Unknown';
  return sprintf('%3.2f m/s', [speed]);
}

String? getCountryCode(String operatorId) {
  if (operatorId.length >= 3) {
    return operatorId.substring(0, 3);
  }
  return null;
}

// validate according to (ANSI/CTA-2063-A)
// SN = [4 Character MFR CODE][1 Character LENGTH CODE]
//      [15 Character MANUFACTURER’S SERIAL NUMBER]
// returns null if successfull, otherwise it returns error message
String? validateUASID(String text) {
  text = text.removeNonAlphanumeric();
  if (text.length <= 5) return 'Invalid length';
  // 4-char. code, may include a combination of digits and uppercase letters,
  // except the letters O and I.
  final mfr = text.substring(0, 4);
  if (!RegExp(r'^[0-9]*[A-Z]*$').hasMatch(mfr) ||
      mfr.contains('O') ||
      mfr.contains('I')) {
    return 'Invalid Manufacturer code';
  }
  late final int msnLen;
  try {
    msnLen = int.parse(
      text.substring(4, 5),
      radix: 16,
    );
  } catch (_) {
    return 'Invalid lenght code';
  }

  if (msnLen < 1 || msnLen > 15 || text.length - 5 != msnLen) {
    return 'Invalid length';
  }

  final msn = text.substring(5, 5 + msnLen);
  if (msn != msn.removeNonAlphanumeric() ||
      msn.contains('O') ||
      msn.contains('I')) {
    return 'Invalid Manufacturer Serial Number';
  }
  return null;
}
