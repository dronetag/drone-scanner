import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ZoneType {
  airport,
  controlledAirspace,
  specialUseAirspace,
  other,
}

class ZoneItem {
  static const zoneTypeMapping = {
    'airport': ZoneType.airport,
    'controlled_airspace': ZoneType.controlledAirspace,
    'special_use_airspace': ZoneType.specialUseAirspace,
  };

  static final labels = Map.fromIterables(ZoneType.values,
      ['Airport', 'Controlled airspace', 'Special use airspace', 'Other']);

  final String id;
  final String name;

  final double lowerAltitude;
  final double upperAltitude;
  final String? lowerAltitudeRef;
  final String? upperAltitudeRef;
  final String? icao;
  final String? amId;
  final ZoneType type;
  final String? country;
  final String? regionType;
  final double? radius;
  final List<LatLng> coordinates;

  List<Object?> get props => [id, name];

  const ZoneItem({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
    required this.lowerAltitude,
    required this.upperAltitude,
    this.country,
    this.icao,
    this.amId,
    this.lowerAltitudeRef,
    this.upperAltitudeRef,
    this.regionType,
    this.radius,
  });
}
