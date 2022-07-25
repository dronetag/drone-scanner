import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class MapLayerStyleDefinition {
  final String? styleFile;
  final gmap.MapType gmapType;
  final String? data;
  const MapLayerStyleDefinition(this.styleFile, this.gmapType, [this.data]);
}

/// Mapping of map layer state to JSON style file and GMaps map type
const mapStyles = {
  gmap.MapType.normal: MapLayerStyleDefinition(
    'assets/google_maps/map_style_without_poi.json',
    gmap.MapType.normal,
  ),
  /*MapStyle.withPoi: MapLayerStyleDefinition(
    'assets/google_maps/map_style_with_poi.json',
    gmap.MapType.normal,
  ),*/
  gmap.MapType.satellite: MapLayerStyleDefinition(
    null,
    gmap.MapType.satellite,
  ),
};

class GoogleMapStyleReader {
  late Map<gmap.MapType, MapLayerStyleDefinition> layers;

  GoogleMapStyleReader() {
    _preloadAllFiles();
  }

  void _preloadAllFiles() async {
    layers = Map.fromEntries(
      await Future.wait(
        mapStyles.entries.map(
          (entry) async {
            final def = entry.value;
            if (def.styleFile == null) return entry;
            final content = await rootBundle.loadString(def.styleFile!);
            return MapEntry(entry.key,
                MapLayerStyleDefinition(def.styleFile, def.gmapType, content));
          },
        ),
      ),
    );
  }

  String? getStyleJson(gmap.MapType mapType) => layers[mapType]?.data;

  gmap.MapType getGMapType(gmap.MapType mapType) =>
      layers[mapType]?.gmapType ?? gmap.MapType.none;
}
