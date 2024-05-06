part of 'aircraft_metadata_cubit.dart';

class AircraftMetadataState {
  // map of aircraft labels given by user
  // keys are aircraft mac adresses, values are labels
  final Map<String, String> aircraftLabels;
  // map of model info for given aicraft fetched from ornithology service
  final Map<String, AircraftModelInfo> aircraftModelInfo;
  // map of flags image data for country codes
  final Map<String, Uint8List?> countryCodeFlags;

  final bool fetchInProgress;

  AircraftMetadataState({
    required this.aircraftLabels,
    required this.aircraftModelInfo,
    required this.countryCodeFlags,
    required this.fetchInProgress,
  });

  AircraftMetadataState copyWith({
    Map<String, String>? aircraftLabels,
    Map<String, AircraftModelInfo>? aircraftModelInfo,
    Map<String, Uint8List?>? countryCodeFlags,
    bool? fetchInProgress,
  }) =>
      AircraftMetadataState(
        aircraftLabels: aircraftLabels ?? this.aircraftLabels,
        aircraftModelInfo: aircraftModelInfo ?? this.aircraftModelInfo,
        countryCodeFlags: countryCodeFlags ?? this.countryCodeFlags,
        fetchInProgress: fetchInProgress ?? this.fetchInProgress,
      );
}
