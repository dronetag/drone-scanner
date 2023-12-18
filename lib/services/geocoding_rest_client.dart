import '../models/place_details.dart';
import 'rest_client.dart';

const nominatimGeocodingRestApiEndpoint = 'https://nominatim.openstreetmap.org';

abstract class GeocodingRestClient extends RestClient {
  GeocodingRestClient(super.baseUrl);

  Future<List<PlaceDetails>> autocomplete({required String query, int? limit});
}

/// A Client for Nominatim Geocoding API: https://nominatim.openstreetmap.org
/// Nominatim is an Open Source geocoder built for OpenStreetMap data
/// that provides autocomplete and reverse search by location and search by ID.
class NominatimGeocodingRestClient extends GeocodingRestClient {
  NominatimGeocodingRestClient({String? baseUrl})
      : super(Uri.parse(baseUrl ?? nominatimGeocodingRestApiEndpoint));

  @override
  Future<List<PlaceDetails>> autocomplete({
    required String query,
    int? limit,
  }) async {
    final response = await request(HttpMethod.get, 'search', query: {
      'q': query,
      'format': 'json',
      if (limit != null) 'limit': limit.toString(),
    });
    return convertToList(
      response,
      (o) => PlaceDetails.fromJson(o as Map<String, dynamic>),
    );
  }
}
