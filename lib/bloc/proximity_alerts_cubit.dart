import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:localstorage/localstorage.dart';

import '../services/notification_service.dart';
import '../utils/utils.dart';

part 'proximity_alerts_state.dart';

class ProximityAlertsCubit extends Cubit<ProximityAlertsState> {
  static const maxProximityAlertDistance = 2000.0;
  static const minProximityAlertDistance = 100.0;
  static const defaultProximityAlertDistance = 2000.0;

  static const proximityAlertActiveKey = 'proximityAlertActive';
  static const proximityAlertDistanceKey = 'proximityAlertDistance';
  static const usersAircraftUASIDKey = 'usersAircraftUASID';
  static const sendNotificationsKey = 'sendNotifications';
  static const expirationTimeKey = 'expirationTime';

  final NotificationService notificationService;

  final LocalStorage storage = LocalStorage('dronescanner-proximity-alerts');

  final _alertController = StreamController<List<ProximityAlert>>();
  Stream<List<ProximityAlert>> get alertStream => _alertController.stream;

  ProximityAlertsCubit(this.notificationService)
      : super(
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
    _alertController.add([]);
    await fetchSavedData();
  }

  void clearFoundDrones() {
    emit(state.copyWith(foundAircraft: {}));
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
    // turn alert on after setting aircraft
    await storage.setItem(
      proximityAlertActiveKey,
      true,
    );
    await fetchSavedData();
  }

  Future<void> setProximityAlertsDistance(double distance) async {
    await storage.setItem(
      proximityAlertDistanceKey,
      distance,
    );
    await fetchSavedData();
  }

  Future<void> setNotificationExpirationTime(int time) async {
    await storage.setItem(
      expirationTimeKey,
      time,
    );
    await fetchSavedData();
  }

  Future<void> setProximityAlertsActive({required bool active}) async {
    await storage.setItem(
      proximityAlertActiveKey,
      active,
    );
    if (!active) {
      _alertController.add([]);
    }
    await fetchSavedData();
  }

  void setSendNotifications({required bool send}) async {
    await storage.setItem(
      sendNotificationsKey,
      send,
    );
    await fetchSavedData();
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

  void checkProximityAlerts(
      MessagePack pack, Map<String, List<MessagePack>> packHistory) {
    if (!_alertsReady(pack)) {
      return;
    }

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
            if (state.foundAircraft.containsKey(uasId)) {
              final ageMs = DateTime.now().millisecondsSinceEpoch -
                  state.foundAircraft[uasId]!.millisecondsSinceEpoch;
              // TODO: change minutes variable, found out best value
              if (ageMs < Duration(minutes: 2).inMilliseconds) return;
            }
            _sendAlert([
              DroneNearbyAlert(value.last.basicIdMessage!.uasId, distance,
                  state.expirationTimeSec)
            ]);
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
  }
}
