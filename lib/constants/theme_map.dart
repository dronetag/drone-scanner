import 'dart:ui';

import '../bloc/zones/zone_item.dart';

class MapAppTheme {
  static const Color flightRegionFillColor = Color(0x258DBF52);
  static const Color flightRegionStrokeColor = Color(0x556C9D11);
  static const flightRegionStrokeWidth = 2;

  static const airspaceZoneStrokeWidth = 1;

  static const Color selectedZoneColor = Color(0x70AA0000);
  static const Color selectedZoneStrokeColor = Color(0xF0AA0000);
  static const Color defaultZoneColor = Color(0x7000AA00);
  static const Color defaultZoneStrokeColor = Color(0xF000AA00);

  static const airspaceZoneColor = {
    ZoneType.airport: Color(0x30E3BF70),
    ZoneType.controlledAirspace: Color(0x306EA5E4),
    ZoneType.specialUseAirspace: Color(0x30E78F6D),
    ZoneType.other: Color(0x70555555),
  };

  static const airspaceZoneStrokeColor = {
    ZoneType.airport: Color(0xF0E3BF70),
    ZoneType.controlledAirspace: Color(0xF06EA5E4),
    ZoneType.specialUseAirspace: Color(0xF0E78F6D),
    ZoneType.other: Color(0xF0555555),
  };

  static const flightTrajectoryStrokeColor = Color(0xC000A0FF);
  static const flightTrajectoryStrokeWidth = 4;
}
