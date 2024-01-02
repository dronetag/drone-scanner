class PlaceDetails {
  final String osmId;
  final String placeId;
  final String? name;
  final String? localname;
  // names in different languages
  final Map<String, String>? names;
  final String? displayName;
  final String? countryCode;

  final String? latitudeStr;
  final String? longitudeStr;

  final OSMPlaceGeometry? geometry;

  PlaceDetails({
    required this.osmId,
    required this.placeId,
    this.name,
    this.localname,
    this.names,
    this.displayName,
    this.countryCode,
    this.latitudeStr,
    this.longitudeStr,
    this.geometry,
  });

  String? get title => name ?? localname ?? names?['name'];

  String? get address {
    if (displayName != null) return displayName;

    final parts = <String>[];

    if (title != null) parts.add(title!);
    if (countryCode != null) parts.add(countryCode!.toUpperCase());

    if (parts.isEmpty) return null;

    return parts.join(', ');
  }

  double? get latitude =>
      latitudeStr == null ? geometry?.latitude : double.parse(latitudeStr!);

  double? get longitude =>
      longitudeStr == null ? geometry?.longitude : double.parse(longitudeStr!);

  bool get hasValidLocation => latitude != null && longitude != null;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) => PlaceDetails(
        osmId: PlaceDetails.idFromJson(json['osm_id'] as int),
        placeId: PlaceDetails.idFromJson(json['place_id'] as int),
        name: json['name'] as String?,
        localname: json['localname'] as String?,
        names: (json['names'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
        displayName: json['display_name'] as String?,
        countryCode: json['country_code'] as String?,
        latitudeStr: json['lat'] as String?,
        longitudeStr: json['lon'] as String?,
        geometry: json['geometry'] == null
            ? null
            : OSMPlaceGeometry.fromJson(
                json['geometry'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'osm_id': PlaceDetails.idToJson(osmId),
        'place_id': PlaceDetails.idToJson(placeId),
        'name': name,
        'localname': localname,
        'names': names,
        'display_name': displayName,
        'country_code': countryCode,
        'lat': latitudeStr,
        'lon': longitudeStr,
        'geometry': geometry,
      };

  static String idFromJson(int val) => val.toString();
  static int idToJson(String val) => int.parse(val);
}

/// The [OSMPlaceGeometry] object represents a position of a feature from the
/// OpenStreetMap (OSM) database in a coordinate space.
///
/// Coordinates are represented by an array of doubles. There must be al least 2
/// elements. The first two elements are longitude and latitude.
class OSMPlaceGeometry {
  /// An example of coordinates for Berlin, longitude is 1st, latitude 2nd.
  ///   "coordinates": [
  ///     13.438596      --> longitude
  ///     52.519854      --> latitude
  ///   ]
  final List<double> coordinates;
  final String type;

  OSMPlaceGeometry({required this.type, required this.coordinates});

  bool get hasValidLocation => coordinates.length >= 2;

  double? get latitude => hasValidLocation ? coordinates[1] : null;

  double? get longitude => hasValidLocation ? coordinates[0] : null;

  factory OSMPlaceGeometry.fromJson(Map<String, dynamic> json) =>
      OSMPlaceGeometry(
        type: json['type'] as String,
        coordinates: (json['coordinates'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coordinates': coordinates,
        'type': type,
      };
}
