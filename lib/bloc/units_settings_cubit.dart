import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:localstorage/localstorage.dart';

import '../models/unit_value.dart';
import '../services/unit_conversion_service.dart';

part 'units_settings_state.dart';

/// Needs to be initialized by calling the [create] method.
class UnitsSettingsCubit extends Cubit<UnitsSettingsState> {
  // maps of units and their names
  static const speedUnits = UnitsConversionService.speedUnits;
  static const distanceUnits = UnitsConversionService.distanceUnits;
  static const altitudeUnits = UnitsConversionService.altitudeUnits;

  // storage keys
  static const _distanceUnitKey = 'unit_distance';
  static const _speedUnitKey = 'unit_speed';
  static const _altitudeUnitKey = 'unit_altitude';
  static const _useConversionInExportKey = 'use_conversion_in_export';

  final UnitsConversionService unitsConversion = UnitsConversionService();
  final LocalStorage storage = LocalStorage('dronescanner-units-settings');

  UnitsSettingsCubit()
      : super(
          UnitsSettingsState(
            altitudeUnit: UnitsConversionService.defaultAltitudeUnit,
            speedUnit: UnitsConversionService.defaultSpeedUnit,
            distanceUnit: UnitsConversionService.defaultDistanceUnit,
            useConversionInExport: true,
          ),
        );

  Future<UnitsSettingsCubit> create() async {
    await _fetchUnitsSetting();
    return this;
  }

  void updateDistanceUnitsSetting(String newValue) async {
    if (distanceUnits.containsKey(newValue)) {
      await _saveUnitsSetting(newValue, _distanceUnitKey);
      emit(state.copyWith(distanceUnit: newValue));
    }
  }

  void updateSpeedUnitsSetting(String newValue) async {
    if (speedUnits.containsKey(newValue)) {
      await _saveUnitsSetting(newValue, _speedUnitKey);
      emit(state.copyWith(speedUnit: newValue));
    }
  }

  void updateAltitudeUnitsSetting(String newValue) async {
    if (altitudeUnits.containsKey(newValue)) {
      await _saveUnitsSetting(newValue, _altitudeUnitKey);
      emit(state.copyWith(altitudeUnit: newValue));
    }
  }

  void updateUseConversionForExportSetting({required bool newValue}) async {
    await storage.setItem(_useConversionInExportKey, newValue);
    emit(state.copyWith(useConversionInExports: newValue));
  }

  UnitValue distanceDefaultToCurrent(UnitValue value) =>
      unitsConversion.distanceDefaultToCurrent(value, state.distanceUnit);

  UnitValue distanceCurrentToDefault(UnitValue value) =>
      unitsConversion.distanceCurrentToDefault(value, state.distanceUnit);

  UnitValue speedDefaultToCurrent(UnitValue value) =>
      unitsConversion.speedDefaultToCurrent(value, state.speedUnit);

  UnitValue speedCurrentToDefault(UnitValue value) =>
      unitsConversion.speedCurrentToDefault(value, state.speedUnit);

  UnitValue altitudeDefaultToCurrent(UnitValue value) =>
      unitsConversion.altitudeDefaultToCurrent(value, state.altitudeUnit);

  UnitValue altitudeCurrentToDefault(UnitValue value) =>
      unitsConversion.altitudeCurrentToDefault(value, state.altitudeUnit);

  String getAltitudeAsString(double? altitude) =>
      unitsConversion
          .odidAltitudeToCurrentUnit(altitude, state.altitudeUnit)
          ?.toStringAsFixed(1) ??
      'Unknown';

  String getSpeedVertAsString(double? speed) =>
      unitsConversion
          .odidSpeedVertToCurrentUnit(speed, state.speedUnit)
          ?.toStringAsFixed(1) ??
      'Unknown';

  String getSpeedHorAsString(double? speed) =>
      unitsConversion
          .odidSpeedHorToCurrentUnit(speed, state.speedUnit)
          ?.toStringAsFixed(1) ??
      'Unknown';

  String getDirectionAsString(double? direction) =>
      unitsConversion.odidDirectionToUnitValue(direction)?.toStringAsFixed(1) ??
      'Unknown';

  String horizontalAccuracyToString(HorizontalAccuracy? acc) {
    final convertedUnitValue = unitsConversion
        .odidHorizontalAccuracyToCurrentUnit(acc, state.distanceUnit);

    if (convertedUnitValue == null) return 'Unknown';

    return '< ${convertedUnitValue.toStringAsFixed(3)}';
  }

  String verticalAccuracyToString(VerticalAccuracy? acc) {
    final convertedUnitValue = unitsConversion
        .odidVerticalAccuracyToCurrentUnit(acc, state.distanceUnit);

    if (convertedUnitValue == null) return 'Unknown';

    return '< ${convertedUnitValue.toStringAsFixed(3)}';
  }

  String speedAccuracyToString(SpeedAccuracy? acc) {
    final convertedUnitValue =
        unitsConversion.odidSpeedAccuracyToCurrentUnit(acc, state.speedUnit);

    if (convertedUnitValue == null) return 'Unknown';

    return '< ${convertedUnitValue.toStringAsFixed(3)}';
  }

  String timeAccuracyToString(Duration? acc) {
    final convertedUnitValue = unitsConversion.timeAccuracyToUnitValue(acc);

    if (convertedUnitValue == null) return 'Unknown';

    return convertedUnitValue.toString();
  }

  Future<void> _saveUnitsSetting(String newValue, String settingKey) async =>
      await storage.setItem(settingKey, newValue);

  Future<void> _fetchUnitsSetting() async {
    final ready = await storage.ready;
    if (ready) {
      emit(
        UnitsSettingsState(
          altitudeUnit: storage.getItem(_altitudeUnitKey) ??
              UnitsConversionService.defaultAltitudeUnit,
          distanceUnit: storage.getItem(_distanceUnitKey) ??
              UnitsConversionService.defaultDistanceUnit,
          speedUnit: storage.getItem(_speedUnitKey) ??
              UnitsConversionService.defaultSpeedUnit,
          useConversionInExport:
              storage.getItem(_useConversionInExportKey) ?? true,
        ),
      );
    }
  }
}
