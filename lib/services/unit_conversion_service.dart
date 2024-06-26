import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:units_converter/units_converter.dart';

import '../models/unit_value.dart';

/// [UnitsConversionService] converts distance, speed and altitude from
/// default to current units and from current to default.
/// It also converts ODID values to current units to [UnitValue] representation.
class UnitsConversionService {
  // maps of units and their names
  static const speedUnits = {
    'mps': 'Meters per second',
    'kph': 'Kilometers per hour',
    'mph': 'Miles per hour',
    'kt': 'Knots'
  };
  static const distanceUnits = {'km': 'Kilometers', 'mi': 'Miles'};
  static const altitudeUnits = {'m': 'Meters', 'ft': 'Feet'};
  // default units
  static const defaultDistanceUnit = 'km';
  static const defaultDistanceSubUnit = 'm';
  static const defaultSpeedUnit = 'mps';
  static const defaultAltitudeUnit = 'm';

  UnitValue distanceDefaultToCurrent(
          UnitValue value, String currentDistanceUnit) =>
      switch ((currentDistanceUnit, value.unit)) {
        ('mi', 'm') => UnitValue(
            value: value.value
                .toDouble()
                .convertFromTo(LENGTH.meters, LENGTH.yards)!,
            unit: 'yd',
          ),
        ('mi', 'km') => UnitValue(
            value: value.value
                .toDouble()
                .convertFromTo(LENGTH.kilometers, LENGTH.miles)!,
            unit: 'mi',
          ),
        (_, _) => value,
      };

  UnitValue distanceCurrentToDefault(
          UnitValue value, String currentDistanceUnit) =>
      switch ((currentDistanceUnit, value.unit)) {
        ('mi', 'yd') => UnitValue(
            value: value.value.convertFromTo(LENGTH.yards, LENGTH.meters)!,
            unit: 'm',
          ),
        ('mi', _) => UnitValue(
            value: value.value.convertFromTo(LENGTH.miles, LENGTH.kilometers)!,
            unit: defaultDistanceUnit,
          ),
        (_, _) => value,
      };

  UnitValue speedDefaultToCurrent(UnitValue value, String currentSpeedUnit) =>
      switch (currentSpeedUnit) {
        'kph' => UnitValue(
            value: value.value
                .convertFromTo(SPEED.metersPerSecond, SPEED.kilometersPerHour)!,
            unit: 'kph',
          ),
        'mph' => UnitValue(
            value: value.value
                .convertFromTo(SPEED.metersPerSecond, SPEED.milesPerHour)!,
            unit: 'mph',
          ),
        'kt' => UnitValue(
            value:
                value.value.convertFromTo(SPEED.metersPerSecond, SPEED.knots)!,
            unit: 'kt',
          ),
        _ => value,
      };

  UnitValue speedCurrentToDefault(UnitValue value, String currentSpeedUnit) =>
      switch (currentSpeedUnit) {
        'kph' => UnitValue(
            value: value.value
                .convertFromTo(SPEED.kilometersPerHour, SPEED.metersPerSecond)!,
            unit: defaultSpeedUnit,
          ),
        'mph' => UnitValue(
            value: value.value
                .convertFromTo(SPEED.milesPerHour, SPEED.metersPerSecond)!,
            unit: defaultSpeedUnit,
          ),
        'kn' => UnitValue(
            value:
                value.value.convertFromTo(SPEED.knots, SPEED.metersPerSecond)!,
            unit: defaultSpeedUnit,
          ),
        _ => value,
      };

  UnitValue altitudeDefaultToCurrent(
          UnitValue value, String currentAltitudeUnit) =>
      switch (currentAltitudeUnit) {
        'ft' => UnitValue(
            value: value.value.convertFromTo(LENGTH.meters, LENGTH.feet)!,
            unit: 'ft',
          ),
        _ => value,
      };

  UnitValue altitudeCurrentToDefault(
          UnitValue value, String currentAltitudeUnit) =>
      switch (currentAltitudeUnit) {
        'ft' => UnitValue(
            value: value.value.convertFromTo(LENGTH.feet, LENGTH.meters)!,
            unit: defaultAltitudeUnit,
          ),
        _ => value,
      };

  UnitValue? odidAltitudeToCurrentUnit(
      double? altitude, String currentAltitudeUnit) {
    if (altitude == null || altitude == INV_ALT) return null;
    return altitudeDefaultToCurrent(
        UnitValue.meters(altitude), currentAltitudeUnit);
  }

  UnitValue? odidVerticalSpeedToCurrentUnit(
      double? speed, String currentSpeedUnit) {
    if (speed == null || speed == INV_SPEED_V) return null;
    return speedDefaultToCurrent(
        UnitValue.metersPerSecond(speed), currentSpeedUnit);
  }

  UnitValue? odidHorizontalSpeedToCurrentUnit(
      double? speed, String currentSpeedUnit) {
    if (speed == null || speed == INV_SPEED_H) return null;
    return speedDefaultToCurrent(
        UnitValue.metersPerSecond(speed), currentSpeedUnit);
  }

  UnitValue? odidHorizontalAccuracyToCurrentUnit(
      HorizontalAccuracy? acc, String currentDistanceUnit) {
    if (acc == null) return null;
    final unitValue = switch (acc) {
      HorizontalAccuracy.unknown => null,
      HorizontalAccuracy.meters_1 => UnitValue.meters(1),
      HorizontalAccuracy.meters_3 => UnitValue.meters(3),
      HorizontalAccuracy.meters_10 => UnitValue.meters(10),
      HorizontalAccuracy.meters_30 => UnitValue.meters(30),
      HorizontalAccuracy.meters_92_6 => UnitValue.meters(92.6),
      HorizontalAccuracy.meters_185_2 => UnitValue.meters(185.2),
      HorizontalAccuracy.meters_555_6 => UnitValue.meters(555.6),
      HorizontalAccuracy.meters_926 => UnitValue.meters(926),
      HorizontalAccuracy.kilometers_1_852 => UnitValue.meters(1852),
      HorizontalAccuracy.kilometers_3_704 => UnitValue.meters(3704),
      HorizontalAccuracy.kilometers_7_408 => UnitValue.meters(7408),
      HorizontalAccuracy.kilometers_18_52 => UnitValue.meters(18520),
    };

    if (unitValue == null) return null;
    return distanceDefaultToCurrent(unitValue, currentDistanceUnit);
  }

  UnitValue? odidVerticalAccuracyToCurrentUnit(
      VerticalAccuracy? acc, String currentDistanceUnit) {
    if (acc == null) return null;

    final unitValue = switch (acc) {
      VerticalAccuracy.unknown => null,
      VerticalAccuracy.meters_1 => UnitValue.meters(1),
      VerticalAccuracy.meters_3 => UnitValue.meters(3),
      VerticalAccuracy.meters_10 => UnitValue.meters(10),
      VerticalAccuracy.meters_25 => UnitValue.meters(25),
      VerticalAccuracy.meters_45 => UnitValue.meters(45),
      VerticalAccuracy.meters_150 => UnitValue.meters(150),
    };

    if (unitValue == null) return null;
    return distanceDefaultToCurrent(unitValue, currentDistanceUnit);
  }

  UnitValue? odidSpeedAccuracyToCurrentUnit(
      SpeedAccuracy? acc, String currentSpeedUnit) {
    if (acc == null) return null;

    final unitValue = switch (acc) {
      SpeedAccuracy.unknown => null,
      SpeedAccuracy.meterPerSecond_0_3 => UnitValue.metersPerSecond(0.3),
      SpeedAccuracy.meterPerSecond_1 => UnitValue.metersPerSecond(1),
      SpeedAccuracy.meterPerSecond_3 => UnitValue.metersPerSecond(3),
      SpeedAccuracy.meterPerSecond_10 => UnitValue.metersPerSecond(10),
    };

    if (unitValue == null) return null;
    return speedDefaultToCurrent(unitValue, currentSpeedUnit);
  }

  UnitValue? odidTimeAccuracyToUnitValue(Duration? acc) {
    if (acc == null || acc.inMilliseconds == 0) return null;
    return UnitValue.seconds(acc.inMilliseconds / 1000);
  }

  UnitValue? odidDirectionToUnitValue(double? direction) {
    if (direction == null || direction == INV_DIR) return null;

    return UnitValue.degrees(direction);
  }
}
