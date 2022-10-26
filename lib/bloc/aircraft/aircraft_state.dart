part of 'aircraft_cubit.dart';

class AircraftState {
  final Map<String, List<MessagePack>> _packHistory;
  final bool cleanOldPacks;
  final double cleanTimeSec;
  final Map<String, Timer> expiryTimers;

  // map of aircraft labels given by user
  // keys are aircraft mac adresses, values are labels
  final Map<String, String> aircraftLabels;

  Map<String, List<MessagePack>> packHistory() {
    return _packHistory;
  }

  Map<String, List<MessagePack>> packHistoryByLastUpdate() {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (e1.value.last.lastUpdate.isBefore(e2.value.last.lastUpdate)) {
              return 1;
            }
            return -1;
          },
        ),
    );
  }

  Map<String, List<MessagePack>> packHistoryByUASID() {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (e1.value.last.basicIdMessage == null) return 1;
            if (e2.value.last.basicIdMessage == null) return -1;
            return e1.value.last.basicIdMessage!.uasId
                .compareTo(e2.value.last.basicIdMessage!.uasId);
          },
        ),
    );
  }

  Map<String, List<MessagePack>> packHistoryByDistance(LatLng userPos) {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (!e1.value.last.locationValid()) return 0;
            if (!e2.value.last.locationValid()) return 0;

            final e1Dist = calculateDistance(
              e1.value.last.locationMessage!.latitude!,
              e1.value.last.locationMessage!.longitude!,
              userPos.latitude,
              userPos.longitude,
            );
            final e2Dist = calculateDistance(
              e2.value.last.locationMessage!.latitude!,
              e2.value.last.locationMessage!.longitude!,
              userPos.latitude,
              userPos.longitude,
            );
            if (e1Dist < e2Dist) {
              return -1;
            }
            return 1;
          },
        ),
    );
  }

  AircraftState({
    required Map<String, List<MessagePack>> packHistory,
    required this.cleanOldPacks,
    required this.cleanTimeSec,
    required this.aircraftLabels,
    required this.expiryTimers,
  }) : _packHistory = packHistory;

  AircraftState copyWith({
    Map<String, List<MessagePack>>? packHistory,
    bool? cleanOldPacks,
    double? cleanTimeSec,
    Map<String, String>? aircraftLabels,
    Map<String, Timer>? expiryTimers,
  }) =>
      AircraftState(
          packHistory: packHistory ?? _packHistory,
          cleanOldPacks: cleanOldPacks ?? this.cleanOldPacks,
          cleanTimeSec: cleanTimeSec ?? this.cleanTimeSec,
          aircraftLabels: aircraftLabels ?? this.aircraftLabels,
          expiryTimers: expiryTimers ?? this.expiryTimers);
}
