import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class UASIDPrefixReader {
  static Map<String, dynamic>? _uasidPrefixes;

  static const filePath = 'assets/config/uasid_prefix.json';

  static Future<void> initialize() async {
    final configString = await rootBundle.loadString(filePath);
    _uasidPrefixes = json.decode(configString) as Map<String, dynamic>?;
  }

  static String? getManufacturerFromPrefix(String prefix) {
    if (_uasidPrefixes == null) {
      throw StateError(
        'File not found. '
        'Probably file: $filePath was not found or has incorrect format.',
      );
    }
    return _uasidPrefixes![prefix] as String?;
  }

  static String? getManufacturerFromUASID(String uasid) {
    if (_uasidPrefixes == null) {
      throw StateError(
        'File not found. '
        'Probably file: $filePath was not found or has incorrect format.',
      );
    }
    String? res;
    _uasidPrefixes!.forEach((key, value) {
      if (uasid.startsWith(key)) res = value as String;
    });
    return res;
  }
}
