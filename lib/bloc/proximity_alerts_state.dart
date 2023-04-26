part of 'proximity_alerts_cubit.dart';

abstract class ProximityAlert {}

class DroneNearbyAlert extends ProximityAlert {
  final String uasId;
  final double distance;
  final int expirationTimeSec;
  bool expired = false;

  DroneNearbyAlert(this.uasId, this.distance, this.expirationTimeSec);
}

class ProximityAlertsStart extends ProximityAlert {}

class ProximityAlertsState {
  // uas id of drone selected by user as their own
  final String? usersAircraftUASID;
  final double proximityAlertDistance;
  final bool proximityAlertActive;

  final bool sendNotifications;
  final int expirationTimeSec;
  // stored uasid and flag whether alert expired
  final Map<String, DroneNearbyAlert> foundAircraft;

  ProximityAlertsState({
    required this.usersAircraftUASID,
    required this.proximityAlertDistance,
    required this.proximityAlertActive,
    required this.sendNotifications,
    required this.expirationTimeSec,
    required this.foundAircraft,
  });

  ProximityAlertsState copyWith({
    String? usersAircraftUASID,
    double? proximityAlertDistance,
    bool? proximityAlertActive,
    bool? sendNotifications,
    int? expirationTimeSec,
    Map<String, DroneNearbyAlert>? foundAircraft,
  }) =>
      ProximityAlertsState(
        usersAircraftUASID: usersAircraftUASID ?? this.usersAircraftUASID,
        proximityAlertDistance:
            proximityAlertDistance ?? this.proximityAlertDistance,
        proximityAlertActive: proximityAlertActive ?? this.proximityAlertActive,
        sendNotifications: sendNotifications ?? this.sendNotifications,
        expirationTimeSec: expirationTimeSec ?? this.expirationTimeSec,
        foundAircraft: foundAircraft ?? this.foundAircraft,
      );

  ProximityAlertsState updateFoundAircraft(List<DroneNearbyAlert> newlyFound) {
    // remove those already marked as expired
    newlyFound.removeWhere(foundAircraft.containsKey);
    final updated = foundAircraft;
    updated.addAll({for (var e in newlyFound) e.uasId: e});
    return ProximityAlertsState(
      usersAircraftUASID: usersAircraftUASID,
      proximityAlertDistance: proximityAlertDistance,
      proximityAlertActive: proximityAlertActive,
      sendNotifications: sendNotifications,
      expirationTimeSec: expirationTimeSec,
      foundAircraft: updated,
    );
  }

  ProximityAlertsState clearAlreadyShownAircraft() {
    print('taggs clearAlreadyShownAircraft $proximityAlertActive');
    final updated = foundAircraft;
    updated.forEach(
      (key, value) => value.expired = false,
    );
    return ProximityAlertsState(
      usersAircraftUASID: usersAircraftUASID,
      proximityAlertDistance: proximityAlertDistance,
      proximityAlertActive: proximityAlertActive,
      sendNotifications: sendNotifications,
      expirationTimeSec: expirationTimeSec,
      foundAircraft: updated,
    );
  }

  ProximityAlertsState updateAlreadyShownAircraft(List<String> list) {
    final updated = foundAircraft;
    for (var i = 0; i < list.length; ++i) {
      if (updated.containsKey(list[i])) {
        updated[list[i]]!.expired = true;
      }
    }
    return ProximityAlertsState(
      usersAircraftUASID: usersAircraftUASID,
      proximityAlertDistance: proximityAlertDistance,
      proximityAlertActive: proximityAlertActive,
      sendNotifications: sendNotifications,
      expirationTimeSec: expirationTimeSec,
      foundAircraft: updated,
    );
  }

  bool isAlertActiveForId(String? uasId) =>
      uasId != null && usersAircraftUASID == uasId;
}
