import 'dart:typed_data';

import 'rest_client.dart';

const flagCDNRestApiEndpoint = 'https://flagcdn.com';

abstract class FlagRestClient extends RestClient {
  FlagRestClient(super.baseUrl);

  Future<Uint8List?> fetchFlag({
    required String countryCode,
  });
}

class FlagCDNRestClient extends FlagRestClient {
  FlagCDNRestClient({String? baseUrl})
      : super(Uri.parse(baseUrl ?? flagCDNRestApiEndpoint));

  @override
  Future<Uint8List?> fetchFlag({
    required String countryCode,
  }) async {
    final response =
        await request(HttpMethod.get, 'h20/${countryCode.toLowerCase()}.png');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }
}
