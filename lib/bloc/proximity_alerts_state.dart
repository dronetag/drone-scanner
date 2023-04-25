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
  // stored uasid and timestamp for found aircraft
  final Map<String, DateTime> foundAircraft;

  final Set<String> alreadyShownAlerts;

  ProximityAlertsState({
    required this.usersAircraftUASID,
    required this.proximityAlertDistance,
    required this.proximityAlertActive,
    required this.sendNotifications,
    required this.expirationTimeSec,
    required this.foundAircraft,
    required this.alreadyShownAlerts,
  });

  ProximityAlertsState copyWith({
    String? usersAircraftUASID,
    double? proximityAlertDistance,
    bool? proximityAlertActive,
    bool? sendNotifications,
    int? expirationTimeSec,
    Map<String, DateTime>? foundAircraft,
    Set<String>? alreadyShownAlerts,
  }) =>
      ProximityAlertsState(
        usersAircraftUASID: usersAircraftUASID ?? this.usersAircraftUASID,
        proximityAlertDistance:
            proximityAlertDistance ?? this.proximityAlertDistance,
        proximityAlertActive: proximityAlertActive ?? this.proximityAlertActive,
        sendNotifications: sendNotifications ?? this.sendNotifications,
        expirationTimeSec: expirationTimeSec ?? this.expirationTimeSec,
        foundAircraft: foundAircraft ?? this.foundAircraft,
        alreadyShownAlerts: alreadyShownAlerts ?? this.alreadyShownAlerts,
      );

  ProximityAlertsState updateFoundAircraft(List<String> found) {
    final updated = foundAircraft;
    updated.addAll({for (var e in found) e: DateTime.now()});
    return ProximityAlertsState(
      usersAircraftUASID: usersAircraftUASID,
      proximityAlertDistance: proximityAlertDistance,
      proximityAlertActive: proximityAlertActive,
      sendNotifications: sendNotifications,
      expirationTimeSec: expirationTimeSec,
      foundAircraft: updated,
      alreadyShownAlerts: alreadyShownAlerts,
    );
  }

  ProximityAlertsState updateAlreadyShownAircraft(List<String> list) {
    final updated = alreadyShownAlerts;
    updated.addAll(list);
    return ProximityAlertsState(
      usersAircraftUASID: usersAircraftUASID,
      proximityAlertDistance: proximityAlertDistance,
      proximityAlertActive: proximityAlertActive,
      sendNotifications: sendNotifications,
      expirationTimeSec: expirationTimeSec,
      foundAircraft: foundAircraft,
      alreadyShownAlerts: updated,
    );
  }

  bool isAlertActiveForId(String? uasId) =>
      uasId != null && usersAircraftUASID == uasId;
}
