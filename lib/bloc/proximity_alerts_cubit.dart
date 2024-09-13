import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rxdart/rxdart.dart';

import '../services/notification_service.dart';
import '../utils/utils.dart';
import 'aircraft/aircraft_cubit.dart';

part 'proximity_alerts_state.dart';

abstract class AlertUpdate {}

class AlertStart extends AlertUpdate {}

class AlertStop extends AlertUpdate {}

class AlertShow extends AlertUpdate {}

class AlertExpired extends AlertUpdate {}

class ProximityAlertsCubit extends Cubit<ProximityAlertsState> {
  static const maxProximityAlertDistance = 2000.0;
  static const minProximityAlertDistance = 100.0;
  static const defaultProximityAlertDistance = maxProximityAlertDistance;
  static const alertsUpdateIntervalSec = 1;

  static const proximityAlertActiveKey = 'proximityAlertActive';
  static const proximityAlertDistanceKey = 'proximityAlertDistance';
  static const usersAircraftUASIDKey = 'usersAircraftUASID';
  static const sendNotificationsKey = 'sendNotifications';
  static const expirationTimeKey = 'expirationTime';

  final NotificationService notificationService;
  final AircraftCubit aircraftCubit;

  final LocalStorage storage;

  final StreamController<List<ProximityAlert>> _alertController =
      BehaviorSubject();

  final StreamController<AlertUpdate> _alertEventController =
      StreamController<AlertUpdate>();
  Stream<List<ProximityAlert>> get alertStream => _alertController.stream;
  Stream<AlertUpdate> get alertStateStream => _alertEventController.stream;

  Timer? _refreshTimer;

  ProximityAlertsCubit({
    required this.notificationService,
    required this.aircraftCubit,
    required this.storage,
  }) : super(
          ProximityAlertsState(
            usersAircraftUASID: null,
            proximityAlertDistance: defaultProximityAlertDistance,
            proximityAlertActive: false,
            sendNotifications: true,
            expirationTimeSec: 10,
            foundAircraft: {},
          ),
        ) {
    initProximityAlerts();
  }

  void initProximityAlerts() async {
    await fetchSavedData();
    if (state.proximityAlertActive) {
      _sendStartAlert();
      _startAlerts();
    }
  }

  Future<void> fetchSavedData() async {
    final ready = await storage.ready;
    if (ready) {
      var usersAircraftUASID = storage.getItem(usersAircraftUASIDKey);
      var proximityAlertDistance = storage.getItem(proximityAlertDistanceKey);
      var proximityAlertActive = storage.getItem(proximityAlertActiveKey);
      var sendNotifications = storage.getItem(sendNotificationsKey);
      var expirationTime = storage.getItem(expirationTimeKey);
      emit(
        ProximityAlertsState(
          usersAircraftUASID: usersAircraftUASID == null
              ? null
              : (usersAircraftUASID as String),
          proximityAlertDistance:
              proximityAlertDistance ?? defaultProximityAlertDistance,
          proximityAlertActive: proximityAlertActive == null
              ? false
              : proximityAlertActive as bool,
          sendNotifications:
              sendNotifications == null ? true : sendNotifications as bool,
          expirationTimeSec:
              expirationTime == null ? 10 : expirationTime as int,
          foundAircraft: state.foundAircraft,
        ),
      );
    }
  }

  Future<void> clearUsersAircraftUASID() async {
    await storage.deleteItem(
      usersAircraftUASIDKey,
    );
    await storage.setItem(
      proximityAlertActiveKey,
      false,
    );
    _stopAlerts();
    emit(
      ProximityAlertsState(
        proximityAlertActive: false,
        usersAircraftUASID: null,
        expirationTimeSec: state.expirationTimeSec,
        foundAircraft: state.foundAircraft,
        proximityAlertDistance: state.proximityAlertDistance,
        sendNotifications: state.sendNotifications,
      ),
    );
  }

  void showExpiredAlerts() {
    emit(state.clearAlreadyShownAircraft());
    // show alerts again if there are some
    if (state.foundAircraft.isNotEmpty) {
      _alertEventController.add(AlertShow());
    }
    checkProximityAlerts();
  }

  void clearFoundDrones() {
    emit(state.copyWith(foundAircraft: {}));
  }

  void clearFoundDrone(String? uasid) {
    final updated = state.foundAircraft;
    updated.remove(uasid);
    emit(state.copyWith(foundAircraft: updated));
  }

  Future<void> setUsersAircraftUASID(String uasId) async {
    await storage.setItem(
      usersAircraftUASIDKey,
      uasId,
    );
    await storage.setItem(
      proximityAlertActiveKey,
      true,
    );
    // clear found drones
    emit(
      ProximityAlertsState(
        proximityAlertActive: true,
        usersAircraftUASID: uasId,
        expirationTimeSec: state.expirationTimeSec,
        foundAircraft: {},
        proximityAlertDistance: state.proximityAlertDistance,
        sendNotifications: state.sendNotifications,
      ),
    );
    // turn alert on after setting aircraft
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _startAlerts();
    }
  }

  Future<void> setProximityAlertsDistance(double distance) async {
    await storage.setItem(
      proximityAlertDistanceKey,
      distance,
    );
    emit(state.copyWith(proximityAlertDistance: distance));
  }

  Future<void> setNotificationExpirationTime(int time) async {
    await storage.setItem(
      expirationTimeKey,
      time,
    );
    emit(state.copyWith(expirationTimeSec: time));
  }

  Future<void> setProximityAlertsActive({required bool active}) async {
    if (active && state.usersAircraftUASID == null) return;
    await storage.setItem(
      proximityAlertActiveKey,
      active,
    );
    var newState = state.copyWith(proximityAlertActive: active);
    if (active) {
      newState = newState.copyWith(foundAircraft: {});
      _startAlerts();
    } else {
      _stopAlerts();
    }

    emit(newState);
  }

  void onAlertsExpired() {
    _alertEventController.add(AlertExpired());
    _stopAlerts();
    emit(state.updateAlreadyShownAircraft(state.foundAircraft.keys.toList()));
    if (state.proximityAlertActive) _startAlerts();
  }

  void setSendNotifications({required bool send}) async {
    await storage.setItem(
      sendNotificationsKey,
      send,
    );
    emit(state.copyWith(sendNotifications: send));
  }

  void checkProximityAlerts() {
    if (state.usersAircraftUASID == null ||
        aircraftCubit.findByUasID(state.usersAircraftUASID!) == null) return;
    final pack = aircraftCubit.findByUasID(state.usersAircraftUASID!)!;
    final packHistory = aircraftCubit.state.packHistory();
    final foundAlerts = <DroneNearbyAlert>[];
    if (!_alertsReady(pack)) {
      return;
    }
    packHistory.forEach(
      (key, value) {
        // check if one of uas ids matches with uas id of users aicraft
        if (value.last.containsUasId(state.usersAircraftUASID!) ||
            !value.last.locationValid) {
          return;
        }
        // calculate distance in kilometers, convert to meters
        final distance = calculateDistanceInKm(
                    pack.locationMessage!.location!.latitude,
                    pack.locationMessage!.location!.longitude,
                    value.last.locationMessage!.location!.latitude,
                    value.last.locationMessage!.location!.longitude)
                .value
                .toDouble() *
            1000;

        if (_isNearby(value.last, distance)) {
          final uasId = value.last.preferredBasicIdMessage?.uasID;
          // refresh if not marked as expired
          foundAlerts.add(
            DroneNearbyAlert(uasId?.asString() ?? 'Unknown UAS ID', distance,
                state.expirationTimeSec, DateTime.now()),
          );
          // detected first time, show alert
          if (state.foundAircraft[uasId?.asString()] == null) {
            _alertEventController.add(AlertShow());
            if (state.sendNotifications) {
              notificationService.addNotification(
                'Proximity Alert',
                foundAlerts.length == 1
                    ? 'Drone ${foundAlerts.first.uasId} is '
                        '${foundAlerts.first.distance.toStringAsFixed(2)} '
                        'meters from your drone'
                    : '${foundAlerts.length} drones are flying close',
              );
            }
          }
        }
      },
    );
    if (foundAlerts.isNotEmpty) {
      _sendAlert(foundAlerts);
    }
  }

  void _sendAlert(List<DroneNearbyAlert> dronesNearby) {
    _alertController.add(dronesNearby);
    emit(
      state.updateFoundAircraft(
        dronesNearby,
      ),
    );
  }

  void _sendStartAlert() {
    _alertController.add([ProximityAlertsStart()]);
  }

  // check if owned drone has location, expected uasid
  bool _alertsReady(MessageContainer pack) =>
      state.proximityAlertActive &&
      state.usersAircraftUASID != null &&
      pack.containsUasId(state.usersAircraftUASID!) &&
      pack.locationValid;

  // check distance, consider just packs not older than expiration time
  // distance is in meters
  bool _isNearby(MessageContainer pack, double distance) {
    return distance <= state.proximityAlertDistance &&
        pack.lastUpdate.isAfter(
          DateTime.now().subtract(
            Duration(seconds: state.expirationTimeSec),
          ),
        );
  }

  void _startAlerts() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: alertsUpdateIntervalSec),
      (_) => checkProximityAlerts(),
    );
    checkProximityAlerts();
  }

  void _stopAlerts() {
    _alertEventController.add(AlertStop());
    _refreshTimer?.cancel();
  }
}
