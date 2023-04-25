import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rxdart/rxdart.dart';

import '../services/notification_service.dart';
import '../utils/utils.dart';
import 'aircraft/aircraft_cubit.dart';

part 'proximity_alerts_state.dart';

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

  final LocalStorage storage = LocalStorage('dronescanner-proximity-alerts');

  final StreamController<List<ProximityAlert>> _alertController =
      BehaviorSubject();
  Stream<List<ProximityAlert>> get alertStream => _alertController.stream;

  Timer? _refreshTimer;

  ProximityAlertsCubit(this.notificationService, this.aircraftCubit)
      : super(
          ProximityAlertsState(
            usersAircraftUASID: null,
            proximityAlertDistance: defaultProximityAlertDistance,
            proximityAlertActive: false,
            sendNotifications: true,
            expirationTimeSec: 10,
            foundAircraft: {},
            alreadyShownAlerts: {},
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
          proximityAlertDistance: proximityAlertDistance == null
              ? defaultProximityAlertDistance
              : proximityAlertDistance as double,
          proximityAlertActive: proximityAlertActive == null
              ? false
              : proximityAlertActive as bool,
          sendNotifications:
              sendNotifications == null ? true : sendNotifications as bool,
          expirationTimeSec:
              expirationTime == null ? 10 : expirationTime as int,
          foundAircraft: state.foundAircraft,
          alreadyShownAlerts: state.alreadyShownAlerts,
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
        alreadyShownAlerts: state.alreadyShownAlerts,
        expirationTimeSec: state.expirationTimeSec,
        foundAircraft: state.foundAircraft,
        proximityAlertDistance: state.proximityAlertDistance,
        sendNotifications: state.sendNotifications,
      ),
    );
  }

  void showHiddenAlerts() {
    emit(state.copyWith(alreadyShownAlerts: {}));
    checkProximityAlerts();
  }

  void clearFoundDrone(String uasId) {
    final updated = state.foundAircraft;
    updated.remove(uasId);
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
    emit(
      ProximityAlertsState(
        proximityAlertActive: true,
        usersAircraftUASID: uasId,
        alreadyShownAlerts: state.alreadyShownAlerts,
        expirationTimeSec: state.expirationTimeSec,
        foundAircraft: state.foundAircraft,
        proximityAlertDistance: state.proximityAlertDistance,
        sendNotifications: state.sendNotifications,
      ),
    );
    // turn alert on after setting aircraft
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _startAlerts();
      showHiddenAlerts();
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
    if (state.usersAircraftUASID == null ||
        aircraftCubit.findByUasID(state.usersAircraftUASID!) == null) return;
    await storage.setItem(
      proximityAlertActiveKey,
      active,
    );
    if (!active) {
      _alertController.add([]);
    }
    if (active) {
      _startAlerts();
      showHiddenAlerts();
    } else {
      _stopAlerts();
    }
    emit(state.copyWith(proximityAlertActive: active));
  }

  void onAlertsExpired() {
    _stopAlerts();
    emit(state.updateAlreadyShownAircraft(state.foundAircraft.keys.toList()));
    if (state.proximityAlertActive) _startAlerts();
  }

  void _startAlerts() {
    void callback() => checkProximityAlerts();
    _refreshTimer = Timer.periodic(
      Duration(seconds: alertsUpdateIntervalSec),
      (_) => callback(),
    );
    callback();
  }

  void _stopAlerts() {
    _refreshTimer?.cancel();
  }

  void setSendNotifications({required bool send}) async {
    await storage.setItem(
      sendNotificationsKey,
      send,
    );
    emit(state.copyWith(sendNotifications: send));
  }

  void _sendAlert(List<DroneNearbyAlert> dronesNearby) {
    _alertController.add(dronesNearby);

    emit(
      state.updateFoundAircraft(
        dronesNearby.map<String>((e) => e.uasId).toList(),
      ),
    );
  }

  void _sendStartAlert() {
    _alertController.add([ProximityAlertsStart()]);
  }

  // check if owned drone has location, uasid and is airborne
  bool _alertsReady(MessagePack pack) =>
      state.proximityAlertActive &&
      pack.basicIdMessage?.uasId != null &&
      pack.basicIdMessage?.uasId == state.usersAircraftUASID &&
      pack.locationValid() &&
      pack.locationMessage!.status == AircraftStatus.Airborne;

  // check distance, consider just packs not older than expiration time
  bool _isNearby(MessagePack pack, double distance) =>
      distance <= state.proximityAlertDistance &&
      pack.lastUpdate.isAfter(
        DateTime.now().subtract(
          Duration(seconds: state.expirationTimeSec),
        ),
      );

  void checkProximityAlerts() {
    final pack = aircraftCubit.findByUasID(state.usersAircraftUASID!)!;
    final packHistory = aircraftCubit.state.packHistory();
    if (!_alertsReady(pack)) {
      return;
    }
    final foundAlerts = <DroneNearbyAlert>[];
    packHistory.forEach(
      (key, value) {
        final uasId = value.last.basicIdMessage?.uasId;
        if (uasId != null &&
            uasId != state.usersAircraftUASID &&
            value.last.locationValid()) {
          // calc distance and convert to meters
          final distance = calculateDistance(
                  pack.locationMessage!.latitude!,
                  pack.locationMessage!.longitude!,
                  value.last.locationMessage!.latitude!,
                  value.last.locationMessage!.longitude!) *
              1000;
          // send alart once per intruder
          if (_isNearby(value.last, distance)) {
            // if was found before, check time
            if (!state.alreadyShownAlerts.contains(uasId)) {
              foundAlerts.add(
                  DroneNearbyAlert(uasId, distance, state.expirationTimeSec));
            }

            if (state.sendNotifications) {
              notificationService.addNotification(
                'Proximity Alert',
                'Aircraft ${value.last.basicIdMessage?.uasId} is ${distance.toStringAsFixed(2)} meters from your aircraft',
                DateTime.now().millisecondsSinceEpoch + 1000,
                channel: 'testing',
              );
            }
          }
        }
      },
    );
    _sendAlert(foundAlerts);
  }
}
