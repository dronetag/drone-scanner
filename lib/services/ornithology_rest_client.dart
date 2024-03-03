import '../models/aircraft_model_info.dart';
import 'rest_client.dart';

const ornitologyRestApiEndpoint = 'https://ornithology.dronetag.app';

class OrnithologyRestClient extends RestClient {
  OrnithologyRestClient() : super(Uri.parse(ornitologyRestApiEndpoint));

  Future<AircraftModelInfo?> fetchAircraftModelInfo(
      {required String serialNumber}) async {
    final response = await super.request(
      HttpMethod.get,
      query: {'serial_number': serialNumber},
      '/',
    );

    if (response.statusCode != 200) return null;

    return convertToObject(
      response,
      (o) => AircraftModelInfo.fromJson(o as Map<String, dynamic>),
    );
  }
}
