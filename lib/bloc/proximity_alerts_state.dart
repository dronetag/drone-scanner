part of 'proximity_alerts_cubit.dart';

abstract class ProximityAlert {}

class DroneNearbyAlert extends ProximityAlert {
  final String uasId;
  final double distance;
  final int expirationTimeSec;

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

  ProximityAlertsState({
    required this.usersAircraftUASID,
    required this.proximityAlertDistance,
    required this.proximityAlertActive,
    required this.sendNotifications,
    required this.expirationTimeSec,
  });

  ProximityAlertsState copyWith({
    String? usersAircraftUASID,
    double? proximityAlertDistance,
    bool? proximityAlertActive,
    bool? sendNotifications,
    int? expirationTimeSec,
  }) =>
      ProximityAlertsState(
        usersAircraftUASID: usersAircraftUASID ?? this.usersAircraftUASID,
        proximityAlertDistance:
            proximityAlertDistance ?? this.proximityAlertDistance,
        proximityAlertActive: proximityAlertActive ?? this.proximityAlertActive,
        sendNotifications: sendNotifications ?? this.sendNotifications,
        expirationTimeSec: expirationTimeSec ?? this.expirationTimeSec,
      );

  bool isAlertActiveForId(String? uasId) =>
      uasId != null && usersAircraftUASID == uasId;
}
