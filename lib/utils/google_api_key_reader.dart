import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GoogleApiKeyReader {
  static Map<String, dynamic>? _config;

  static const filePath = 'assets/config/google_map_api.json';

  static Future<void> initialize() async {
    final configString = await rootBundle.loadString(filePath);
    _config = json.decode(configString) as Map<String, dynamic>?;
  }

  static String? getApiKey() {
    if (_config == null) {
      throw StateError(
        'Google API key not found. '
        'Probably file: $filePath was not found or API key is not correct.',
      );
    }
    return _config!['apiKey'] as String?;
  }
}
