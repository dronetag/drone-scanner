import 'package:flutter/foundation.dart';

@immutable
class UnitValue {
  final num value;

  final String unit;

  const UnitValue({
    required this.value,
    required this.unit,
  });

  double roundedValue(int fractionalDigits) =>
      double.parse(value.toStringAsFixed(fractionalDigits));

  String toStringRounded() => '${value.round()} $unit';

  String toStringAsFixed(int fractionDigits) =>
      '${value.toStringAsFixed(fractionDigits)} $unit';

  String toStringAsPrecision(int precision) =>
      '${value.toStringAsPrecision(precision)} $unit';

  @override
  String toString() => '$value $unit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitValue &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          unit == other.unit;

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;

  static UnitValue meters(num value) => UnitValue(value: value, unit: 'm');

  static UnitValue kilometers(num value) => UnitValue(value: value, unit: 'km');

  static UnitValue miles(num value) => UnitValue(value: value, unit: 'mi');

  static UnitValue yards(num value) => UnitValue(value: value, unit: 'yd');

  static UnitValue degrees(num value) => UnitValue(value: value, unit: '°');

  static UnitValue seconds(num value) => UnitValue(value: value, unit: 's');

  static UnitValue metersPerSecond(num value) =>
      UnitValue(value: value, unit: 'm/s');
}
