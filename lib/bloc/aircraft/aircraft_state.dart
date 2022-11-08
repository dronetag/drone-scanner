part of 'aircraft_cubit.dart';

class AircraftState {
  final Map<String, List<MessagePack>> _packHistory;
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
    required this.aircraftLabels,
  }) : _packHistory = packHistory;

  AircraftState copyWith({
    Map<String, List<MessagePack>>? packHistory,
    Map<String, String>? aircraftLabels,
  }) =>
      AircraftState(
        packHistory: packHistory ?? _packHistory,
        aircraftLabels: aircraftLabels ?? this.aircraftLabels,
      );
}

class AircraftStateUpdate extends AircraftState {
  AircraftStateUpdate(
      {required Map<String, List<MessagePack>> packHistory,
      required Map<String, String> aircraftLabels})
      : super(packHistory: packHistory, aircraftLabels: aircraftLabels);
}

class AircraftStateBuffering extends AircraftState {
  AircraftStateBuffering(
      {required Map<String, List<MessagePack>> packHistory,
      required Map<String, String> aircraftLabels})
      : super(packHistory: packHistory, aircraftLabels: aircraftLabels);
}
