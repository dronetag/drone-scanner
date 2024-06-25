import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logging/logging.dart';

import '../../exceptions/invalid_country_code_exception.dart';
import '../../models/aircraft_model_info.dart';
import '../../services/flag_rest_client.dart';
import '../../services/ornithology_rest_client.dart';

part 'aircraft_metadata_state.dart';

/// The [AircraftMetadataCubit] fetches and stores aircraft labes, aircraft
/// manufacturer information and flags for country codes of Operator ID.
///
/// Needs to be initialized by calling the [create] method.
class AircraftMetadataCubit extends Cubit<AircraftMetadataState> {
  // storage for user-given labels
  final LocalStorage storage;
  final OrnithologyRestClient ornithologyRestClient;
  final FlagRestClient flagRestClient;

  // alpha-3 to alpha-2 country code conversion
  late Map<String, String> _countryCodeMapping;

  static const _countryCodeMappingPath =
      'assets/country_codes/country_codes.json';
  static const _labelsKey = 'labels';
  static const _modelInfoKey = 'model_info';
  static const _flagsKey = 'flags';

  AircraftMetadataCubit({
    required this.ornithologyRestClient,
    required this.flagRestClient,
    required this.storage,
  }) : super(
          AircraftMetadataState(
            aircraftLabels: <String, String>{},
            aircraftModelInfo: <String, AircraftModelInfo>{},
            countryCodeFlags: <String, Uint8List>{},
            fetchInProgress: false,
          ),
        );

  Future<AircraftMetadataCubit> create() async {
    await fetchSavedAircraftLabels();
    await fetchSavedModelInfo();
    await fetchSavedFlags();

    final countryCodesContent =
        await rootBundle.loadString(_countryCodeMappingPath);
    _countryCodeMapping =
        (json.decode(countryCodesContent) as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as String));

    return this;
  }

  // Retrieves the labels stored persistently locally on the device
  Future<void> fetchSavedAircraftLabels() async {
    final ready = await storage.ready;
    if (ready) {
      var labels = storage.getItem(_labelsKey);
      final labelsMap = <String, String>{};
      if (labels != null) {
        (json.decode(labels as String) as Map<String, dynamic>)
            .forEach((key, value) => labelsMap[key] = value as String);
      }
      emit(
        state.copyWith(
          aircraftLabels: labelsMap,
        ),
      );
    }
  }

  // Retrieves the model info stored persistently locally on the device
  Future<void> fetchSavedModelInfo() async {
    final ready = await storage.ready;
    if (ready) {
      var storedModelInfo = storage.getItem(_modelInfoKey);
      final modelInfo = <String, AircraftModelInfo>{};
      if (storedModelInfo != null) {
        (json.decode(storedModelInfo as String) as Map<String, dynamic>)
            .forEach((key, value) =>
                modelInfo[key] = AircraftModelInfo.fromJson(value));
      }
      emit(
        state.copyWith(
          aircraftModelInfo: modelInfo,
        ),
      );
    }
  }

  // Retrieves the flags stored persistently locally on the device
  Future<void> fetchSavedFlags() async {
    final ready = await storage.ready;
    if (ready) {
      var flags = storage.getItem(_flagsKey);
      final flagsMap = <String, Uint8List?>{};

      if (flags != null) {
        (json.decode(flags as String) as Map<String, dynamic>).forEach(
          (key, value) => flagsMap[key] = value == null
              ? null
              : Uint8List.fromList(List.castFrom<dynamic, int>(value)),
        );
      }
      emit(
        state.copyWith(
          countryCodeFlags: flagsMap,
        ),
      );
    }
  }

  Future<void> fetchModelInfo(String serialNumber) async {
    try {
      emit(state.copyWith(fetchInProgress: true));
      final modelInfo = await ornithologyRestClient.fetchAircraftModelInfo(
          serialNumber: serialNumber);
      if (modelInfo == null) {
        Logger.root.warning('Aircraft model info for $serialNumber is unknown');
        emit(state.copyWith(fetchInProgress: false));
        return;
      }
      emit(
        state.copyWith(aircraftModelInfo: {
          ...state.aircraftModelInfo,
          serialNumber: modelInfo
        }, fetchInProgress: false),
      );
      await _saveModelInfo();
    } on ClientException catch (err) {
      Logger.root.warning(
          'Failed to fetch aircraft model info for $serialNumber, $err');
      emit(state.copyWith(fetchInProgress: false));
    }
  }

  Future<void> fetchFlagForAlpha3Code(String alpha3CountryCode) async {
    if (state.countryCodeFlags.containsKey(alpha3CountryCode)) {
      return;
    }

    try {
      emit(state.copyWith(fetchInProgress: true));
      final alpha2CountryCode = _countryCodeMapping[alpha3CountryCode];

      if (alpha2CountryCode == null) {
        throw InvalidCountryCodeException(
            'Invalid country code: $alpha3CountryCode');
      }

      final flag =
          await flagRestClient.fetchFlag(countryCode: alpha2CountryCode);
      if (flag == null) {
        Logger.root.warning(
            'Unable to fetch flag for country code $alpha2CountryCode');
        return;
      }

      emit(
        state.copyWith(
          countryCodeFlags: {
            ...state.countryCodeFlags,
            alpha3CountryCode: flag,
          },
          fetchInProgress: false,
        ),
      );
      await _saveFlags();
    } catch (err) {
      Logger.root.warning('Failed to fetch flag for $alpha3CountryCode, $err');

      // if InvalidCountryCodeException is thrown, save emptry flag for code
      // and proceed normally
      if (err is! InvalidCountryCodeException) rethrow;

      emit(
        state.copyWith(
          countryCodeFlags: {
            ...state.countryCodeFlags,
            alpha3CountryCode: null,
          },
          fetchInProgress: false,
        ),
      );
      await _saveFlags();
    }
  }

  // Stores the label persistently locally on the device
  Future<void> addAircraftLabel(String mac, String label) async {
    var labels = state.aircraftLabels;
    labels[mac] = label;
    emit(
      state.copyWith(aircraftLabels: labels),
    );
    await _saveLabels();
  }

  // deletes locally stored label for aircraft with given mac
  Future<void> deleteAircraftLabel(String mac) async {
    var labels = state.aircraftLabels;
    labels.remove(mac);
    emit(
      state.copyWith(aircraftLabels: labels),
    );
    await _saveLabels();
  }

  String? getAircraftLabel(String mac) {
    return state.aircraftLabels[mac];
  }

  AircraftModelInfo? getModelInfo(String uasId) {
    return state.aircraftModelInfo[uasId];
  }

  Future<void> clearModelInfo() async {
    final ready = await storage.ready;
    if (ready) {
      await storage.deleteItem(_modelInfoKey);
      emit(state.copyWith(aircraftModelInfo: {}));
    }
  }

  Future<void> clearFlags() async {
    final ready = await storage.ready;
    if (ready) {
      await storage.deleteItem(_flagsKey);
      emit(state.copyWith(countryCodeFlags: {}));
    }
  }

  Future<void> _saveLabels() async =>
      await storage.setItem(_labelsKey, json.encode(state.aircraftLabels));

  Future<void> _saveModelInfo() async => await storage.setItem(
        _modelInfoKey,
        json.encode(
          state.aircraftModelInfo.map(
            (key, value) => MapEntry(key, value.toJson()),
          ),
        ),
      );

  Future<void> _saveFlags() async =>
      await storage.setItem(_flagsKey, json.encode(state.countryCodeFlags));
}
