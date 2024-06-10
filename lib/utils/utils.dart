import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import '../extensions/string_extensions.dart';
import '../models/unit_value.dart';

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
UnitValue calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  const c = math.cos;
  final a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return UnitValue.kilometers(12742 * math.asin(math.sqrt(a)));
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
