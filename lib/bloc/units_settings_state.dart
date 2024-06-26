part of 'units_settings_cubit.dart';

class UnitsSettingsState {
  final String distanceUnit;
  final String speedUnit;
  final String altitudeUnit;
  final bool useConversionInExport;

  UnitsSettingsState({
    required this.distanceUnit,
    required this.speedUnit,
    required this.altitudeUnit,
    required this.useConversionInExport,
  });

  UnitsSettingsState copyWith({
    String? distanceUnit,
    String? speedUnit,
    String? altitudeUnit,
    bool? useConversionInExport,
  }) =>
      UnitsSettingsState(
        distanceUnit: distanceUnit ?? this.distanceUnit,
        speedUnit: speedUnit ?? this.speedUnit,
        altitudeUnit: altitudeUnit ?? this.altitudeUnit,
        useConversionInExport:
            useConversionInExport ?? this.useConversionInExport,
      );

  String get distanceSubUnit =>
      distanceUnit == UnitsConversionService.defaultDistanceUnit ? 'm' : 'yd';

  String get exportDistanceUnit => useConversionInExport
      ? distanceUnit
      : UnitsConversionService.defaultDistanceUnit;

  String get exportDistanceSubUnit => useConversionInExport
      ? distanceSubUnit
      : UnitsConversionService.defaultDistanceSubUnit;

  String get exportAltitudeUnit => useConversionInExport
      ? altitudeUnit
      : UnitsConversionService.defaultAltitudeUnit;

  String get exportSpeedUnit => useConversionInExport
      ? speedUnit
      : UnitsConversionService.defaultSpeedUnit;
}
