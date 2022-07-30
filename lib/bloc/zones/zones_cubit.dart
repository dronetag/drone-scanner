import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'zone_item.dart';

class ZonesState {
  final List<ZoneItem> zones;

  ZonesState({required this.zones});

  static ZonesState get dummyZones => ZonesState(
        zones: [
          ZoneItem(
            id: 'd013e3424fa0-6brw70-42419-83asd5-a8256db',
            name: 'LKR9 (Prague)',
            type: ZoneItem.zoneTypeMapping['controlled_airspace'] as ZoneType,
            lowerAltitudeRef: 'AGL',
            upperAltitudeRef: 'QNH',
            amId: 'b09qe7c4809-244-34',
            lowerAltitude: 0.0,
            upperAltitude: 5000.0,
            country: 'CZ',
            regionType: 'Circle',
            radius: 5556,
            coordinates: [
              const LatLng(50.083214, 14.435139),
            ],
          ),
          ZoneItem(
            id: '123e3424fa0-6bfb70-42419-83asd5-a8256db',
            name: 'LKP1 PRAZSKÝ HRAD',
            type: ZoneItem.zoneTypeMapping['controlled_airspace'] as ZoneType,
            lowerAltitudeRef: 'AGL',
            upperAltitudeRef: 'QNH',
            amId: '70924809-244-34',
            lowerAltitude: 0.0,
            upperAltitude: 5000.0,
            country: 'CZ',
            regionType: 'Circle',
            radius: 1100,
            coordinates: [
              const LatLng(50.090833, 14.400556),
            ],
          ),
          ZoneItem(
            id: '55ee34afa0-4dfb70-43419-8319-8aed5-a82f9db',
            name: 'M.R STEFANIK',
            type: ZoneItem.zoneTypeMapping['airport'] as ZoneType,
            lowerAltitudeRef: 'AGL',
            upperAltitudeRef: 'QNH',
            amId: '70924809-244-34',
            lowerAltitude: 0.0,
            upperAltitude: 5000.0,
            country: 'SK',
            regionType: 'Circle',
            radius: 8006,
            coordinates: [
              const LatLng(48.17, 17.213333),
            ],
          ),
        ],
      );
}

class ZonesCubit extends Cubit<ZonesState> {
  ZonesCubit()
      : super(
          ZonesState.dummyZones,
        );

  Future<bool> fetchAndSetZones() async {
    final url = Uri(
      scheme: 'https',
      host: 'api.staging.dronetag.app',
      path: 'v1/airspace/zones',
    );
    try {
      final response = await http.get(url);
      // ignore: omit_local_variable_types
      List<ZoneItem> loadedZones = [];
      // map with string keys, value is another map
      final extractedData = json.decode(response.body) as List;

      for (var prodData in extractedData) {
        var coords = <LatLng>[];
        for (List<double> coordData in prodData['region']['coordinates'][0]) {
          coords.add(LatLng(coordData[0], coordData[1]));
        }
        loadedZones.add(
          ZoneItem(
            id: prodData['id'] is String ? prodData['id'] as String : '',
            name: prodData['name'] is String ? prodData['name'] as String : '',
            country: prodData['country'] is String
                ? prodData['country'] as String
                : '',
            lowerAltitudeRef:
                prodData['properties']['lower_altitude_ref'] is String
                    ? prodData['properties']['lower_altitude_ref'] as String
                    : '',
            upperAltitudeRef:
                prodData['properties']['upper_altitude_ref'] is String
                    ? prodData['properties']['upper_altitude_ref'] as String
                    : '',
            amId: prodData['properties']['am_id'] is String
                ? prodData['properties']['am_id'] as String
                : '',
            coordinates: coords,
            lowerAltitude: 0,
            upperAltitude: 0,
            type: ZoneType.controlledAirspace,
          ),
        );
      }
      final newZones = state.zones;
      newZones.addAll(loadedZones);
      emit(ZonesState(zones: newZones));
      return true;
    } on Exception {
      return false;
    }
  }
}
