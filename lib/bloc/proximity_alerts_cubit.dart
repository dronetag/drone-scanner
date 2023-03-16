import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:localstorage/localstorage.dart';

import '../utils/utils.dart';

class ProximityAlertsState {
  // uas id of drone selected by user as their own
  final String? usersAircraftUASID;
  final double proximityAlertDistance;
  final bool proximityAlertActive;
  final String? alert;

  ProximityAlertsState({
    required this.usersAircraftUASID,
    required this.proximityAlertDistance,
    required this.proximityAlertActive,
    this.alert,
  });

  ProximityAlertsState copyWith({
    String? usersAircraftUASID,
    double? proximityAlertDistance,
    bool? proximityAlertActive,
    String? alert,
  }) =>
      ProximityAlertsState(
        usersAircraftUASID: usersAircraftUASID ?? this.usersAircraftUASID,
        proximityAlertDistance:
            proximityAlertDistance ?? this.proximityAlertDistance,
        proximityAlertActive: proximityAlertActive ?? this.proximityAlertActive,
        alert: alert ?? this.alert,
      );
}

class ProximityAlertsCubit extends Cubit<ProximityAlertsState> {
  static const maxProximityAlertDistance = 5000.0;
  static const minProximityAlertDistance = 100.0;
  static const defaultProximityAlertDistance = 2000.0;

  static const proximityAlertActiveKey = 'proximityAlertActive';
  static const proximityAlertDistanceKey = 'proximityAlertDistance';
  static const usersAircraftUASIDKey = 'usersAircraftUASID';

  final LocalStorage storage = LocalStorage('dronescanner-proximity-alerts');

  ProximityAlertsCubit()
      : super(
          ProximityAlertsState(
            usersAircraftUASID: null,
            proximityAlertDistance: defaultProximityAlertDistance,
            proximityAlertActive: false,
          ),
        ) {
    fetchSavedData();
  }

  //Retrieves the labels stored persistently locally on the device
  Future<void> fetchSavedData() async {
    final ready = await storage.ready;
    if (ready) {
      var usersAircraftUASID = storage.getItem(usersAircraftUASIDKey);
      var proximityAlertDistance = storage.getItem(proximityAlertDistanceKey);
      var proximityAlertActive = storage.getItem(proximityAlertActiveKey);
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
          alert: null,
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
    await fetchSavedData();
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

  Future<void> setProximityAlertsActive({required bool active}) async {
    await storage.setItem(
      proximityAlertActiveKey,
      active,
    );
    await fetchSavedData();
  }

  void checkProximityAlerts(
      MessagePack pack, Map<String, List<MessagePack>> packHistory) {
    if (state.proximityAlertActive &&
        pack.basicIdMessage?.uasId != null &&
        pack.basicIdMessage?.uasId == state.usersAircraftUASID &&
        pack.locationValid()) {
      packHistory.forEach(
        (key, value) {
          if (value.last.basicIdMessage?.uasId != null &&
              value.last.basicIdMessage?.uasId != state.usersAircraftUASID &&
              value.last.locationValid()) {
            // calc distance and convert to meters
            final distance = calculateDistance(
                    pack.locationMessage!.latitude!,
                    pack.locationMessage!.longitude!,
                    value.last.locationMessage!.latitude!,
                    value.last.locationMessage!.longitude!) *
                1000;
            // consider just packs not older than 30s
            if (distance <= state.proximityAlertDistance &&
                value.last.lastUpdate
                    .isAfter(DateTime.now().subtract(Duration(seconds: 30)))) {
              print('taggs calculated distance btw ${state.usersAircraftUASID}'
                  'and ${value.last.basicIdMessage?.uasId} is $distance, smaller than ${state.proximityAlertDistance}');
              print('taggs ALERT ALERT ALERT');
              final alert =
                  'Warning! Aircraft ${value.last.basicIdMessage?.uasId} is ${distance.toStringAsFixed(2)} meters from your aircraft';
              emit(state.copyWith(alert: alert));
            } else if (state.alert != null) {
              emit(state.copyWith(alert: null));
            }
          }
        },
      );
    } else if (state.alert != null) {
      emit(state.copyWith(alert: null));
    }
  }
}
