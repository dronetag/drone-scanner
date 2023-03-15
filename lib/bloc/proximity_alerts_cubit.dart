import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:localstorage/localstorage.dart';

import '../utils/utils.dart';

class ProximityAlertsState {
  // uas id of drone selected by user as their own
  final String? usersAircraftUASID;
  final double proximityAlertDistance;
  final bool proximityAlertActive;

  ProximityAlertsState({
    required this.usersAircraftUASID,
    required this.proximityAlertDistance,
    required this.proximityAlertActive,
  });

  ProximityAlertsState copyWith({
    String? usersAircraftUASID,
    double? proximityAlertDistance,
    bool? proximityAlertActive,
  }) =>
      ProximityAlertsState(
        usersAircraftUASID: usersAircraftUASID ?? this.usersAircraftUASID,
        proximityAlertDistance:
            proximityAlertDistance ?? this.proximityAlertDistance,
        proximityAlertActive: proximityAlertActive ?? this.proximityAlertActive,
      );
}

class ProximityAlertsCubit extends Cubit<ProximityAlertsState> {
  static const maxProximityAlertDistance = 5000.0;
  static const minProximityAlertDistance = 100.0;
  static const defaultProximityAlertDistance = 2000.0;
  static const proximityAlertStep = 10.0;

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
      var usersAircraftUASID = storage.getItem('usersAircraftUASID');
      var proximityAlertDistance = storage.getItem('proximityAlertDistance');
      var proximityAlertActive = storage.getItem('proximityAlertActive');
      emit(
        state.copyWith(
          usersAircraftUASID: (usersAircraftUASID as String),
          proximityAlertDistance: proximityAlertDistance == null
              ? defaultProximityAlertDistance
              : proximityAlertDistance as double,
          proximityAlertActive: proximityAlertActive == null
              ? false
              : proximityAlertActive as bool,
        ),
      );
    }
  }

  Future<void> setUsersAircraftUASID(String uasId) async {
    await storage.setItem(
      'usersAircraftUASID',
      uasId,
    );
    await fetchSavedData();
  }

  Future<void> setProximityAlertsDistance(double distance) async {
    await storage.setItem(
      'proximityAlertDistance',
      distance,
    );
    await fetchSavedData();
  }

  Future<void> setProximityAlertsActive({required bool active}) async {
    await storage.setItem(
      'proximityAlertActive',
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
            if (distance <= state.proximityAlertDistance) {
              print('taggs calculated distance btw ${state.usersAircraftUASID}'
                  'and ${value.last.basicIdMessage?.uasId} is $distance, smaller than ${state.proximityAlertDistance}');
              print('taggs ALERT ALERT ALERT');
            }
          }
        },
      );
    }
  }
}
