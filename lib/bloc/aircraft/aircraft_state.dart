part of 'aircraft_cubit.dart';

class AircraftState {
  final Map<String, List<MessageContainer>> _packHistory;
  // map of aircraft labels given by user
  // keys are aircraft mac adresses, values are labels
  final Map<String, String> aircraftLabels;
  // map of model info for given aicraft fetched from ornithology service
  final Map<String, AircraftModelInfo> aircraftModelInfo;

  final bool fetchInProgress;

  Map<String, List<MessageContainer>> packHistory(
      [String? userAircraftUasId, MyDronePositioning? myDronePositioning]) {
    return _positionUsersAircraft(
      _packHistory,
      userAircraftUasId,
      myDronePositioning,
    );
  }

  Map<String, List<MessageContainer>> packHistoryByLastUpdate(
      String? userAircraftUasId, MyDronePositioning? myDronePositioning) {
    return _positionUsersAircraft(
      Map.fromEntries(
        _packHistory.entries.toList()
          ..sort(
            (e1, e2) {
              if (e1.value.last.lastUpdate.isBefore(e2.value.last.lastUpdate)) {
                return 1;
              }
              return -1;
            },
          ),
      ),
      userAircraftUasId,
      myDronePositioning,
    );
  }

  Map<String, List<MessageContainer>> packHistoryByUASID(
      String? userAircraftUasId, MyDronePositioning? myDronePositioning) {
    return _positionUsersAircraft(
      Map.fromEntries(
        _packHistory.entries.toList()
          ..sort(
            (e1, e2) {
              if (e1.value.last.preferredBasicIdMessage?.uasID.asString() ==
                  null) {
                return 1;
              }
              if (e2.value.last.preferredBasicIdMessage?.uasID.asString() ==
                  null) {
                return -1;
              }
              return e1.value.last.preferredBasicIdMessage!.uasID
                  .toString()
                  .compareTo(
                      e2.value.last.preferredBasicIdMessage!.uasID.asString()!);
            },
          ),
      ),
      userAircraftUasId,
      myDronePositioning,
    );
  }

  Map<String, List<MessageContainer>> packHistoryByDistance(LatLng userPos,
      String? userAircraftUasId, MyDronePositioning? myDronePositioning) {
    return _positionUsersAircraft(
      Map.fromEntries(
        _packHistory.entries.toList()
          ..sort(
            (e1, e2) {
              if (!e1.value.last.locationValid) return 0;
              if (!e2.value.last.locationValid) return 0;

              final e1Dist = calculateDistance(
                e1.value.last.locationMessage!.location!.latitude,
                e1.value.last.locationMessage!.location!.longitude,
                userPos.latitude,
                userPos.longitude,
              );
              final e2Dist = calculateDistance(
                e2.value.last.locationMessage!.location!.latitude,
                e2.value.last.locationMessage!.location!.longitude,
                userPos.latitude,
                userPos.longitude,
              );
              if (e1Dist < e2Dist) {
                return -1;
              }
              return 1;
            },
          ),
      ),
      userAircraftUasId,
      myDronePositioning,
    );
  }

  Map<String, List<MessageContainer>> _positionUsersAircraft(
      Map<String, List<MessageContainer>> aircraft,
      String? userAircraftUasId,
      MyDronePositioning? myDronePositioning) {
    if (myDronePositioning != null &&
        myDronePositioning != MyDronePositioning.defaultPosition &&
        userAircraftUasId != null &&
        aircraft.values.any((e) => e.last.containsUasId(userAircraftUasId))) {
      final entryList = aircraft.entries.toList();
      final priorityData = entryList.firstWhere(
          (element) => element.value.last.containsUasId(userAircraftUasId));
      entryList.remove(priorityData);
      entryList.insert(
        myDronePositioning == MyDronePositioning.alwaysFirst
            ? 0
            : entryList.length,
        priorityData,
      );
      return Map.fromEntries(entryList);
    }
    return aircraft;
  }

  AircraftState({
    required Map<String, List<MessageContainer>> packHistory,
    required this.aircraftLabels,
    required this.aircraftModelInfo,
    required this.fetchInProgress,
  }) : _packHistory = packHistory;

  AircraftState copyWith({
    Map<String, List<MessageContainer>>? packHistory,
    Map<String, String>? aircraftLabels,
    Map<String, AircraftModelInfo>? aircraftModelInfo,
    bool? fetchInProgress,
  }) =>
      AircraftState(
        packHistory: packHistory ?? _packHistory,
        aircraftLabels: aircraftLabels ?? this.aircraftLabels,
        aircraftModelInfo: aircraftModelInfo ?? this.aircraftModelInfo,
        fetchInProgress: fetchInProgress ?? this.fetchInProgress,
      );
}

class AircraftStateUpdate extends AircraftState {
  AircraftStateUpdate({
    required super.packHistory,
    required super.aircraftLabels,
    required super.aircraftModelInfo,
    required super.fetchInProgress,
  });
}

class AircraftStateBuffering extends AircraftState {
  AircraftStateBuffering({
    required super.packHistory,
    required super.aircraftLabels,
    required super.aircraftModelInfo,
    required super.fetchInProgress,
  });
}
