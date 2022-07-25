import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:sprintf/sprintf.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var c = math.cos;
  var a = 0.5 -
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
  } else if (source == MessageSource.WifiNaN) {
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
  } else if (source == MessageSource.WifiNaN) {
    sourceText = 'N';
  }
  return sourceText;
}

String horizontalAccuracyToString(HorizontalAccuracy? acc) {
  if (acc == null) return 'Unknown';
  switch (acc) {
    case HorizontalAccuracy.Unknown:
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
    case SpeedAccuracy.meter_per_second_10:
      return '< 10 m/s';
    case SpeedAccuracy.meter_per_second_3:
      return '< 3 m/s';
    case SpeedAccuracy.meter_per_second_1:
      return '< 1 m/s';
    case SpeedAccuracy.meter_per_second_0_3:
      return '< 0.3 m/s';
    default:
      return 'Unknown';
  }
}

String timeAccuracyToString(double? acc) {
  if (acc == null) return 'Unknown';
  if (acc == 0) {
    return 'Unknown';
  } else {
    return sprintf('<= %1.1f s', [acc]);
  }
}

String directionAsString(double? direction) {
  if (direction == null) return 'Unknown';
  if (direction != 361) {
    return sprintf('%3.0f °', [direction]);
  } else {
    return ('Unknown');
  }
}

String getAltitudeAsString(double? altitude) {
  if (altitude == null || altitude == -1000) return 'Unknown';
  return sprintf('%3.1f m', [altitude]);
}

Image? getFlag(String countryCode) {
  Image? flag;

  try {
    flag = Image.network(
      'https://flagcdn.com/h20/${countryCode.toLowerCase()}.png',
      width: 24,
      height: 12,
      alignment: Alignment.center,
    );
  } on Exception {
    flag = null;
  }
  return flag;
}
