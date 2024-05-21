import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/message_container_authenticity_status.dart';
import '../../utils/message_container_authenticator.dart';
import '../../utils/utils.dart';
import '../sliders_cubit.dart';
import 'aircraft_expiration_cubit.dart';

part 'aircraft_state.dart';

class AircraftCubit extends Cubit<AircraftState> {
  Timer? _refreshTimer;
  final AircraftExpirationCubit expirationCubit;

  static const uiUpdateIntervalMs = 200;

  // data for showcase
  final List<MessageContainer> _packs = [
    MessageContainer(
      macAddress: '00:00:5e:00:53:ae',
      lastUpdate: DateTime.now(),
      lastMessageRssi: -100,
      source: pigeon.MessageSource.BluetoothLegacy,
      locationMessage: LocationMessage(
        location: const Location(latitude: 50.073058, longitude: 14.411540),
        heightType: HeightType.aboveGroundLevel,
        direction: 1,
        speedAccuracy: SpeedAccuracy.meterPerSecond_0_3,
        verticalAccuracy: VerticalAccuracy.meters_1,
        horizontalAccuracy: HorizontalAccuracy.kilometers_18_52,
        horizontalSpeed: 0.2,
        verticalSpeed: 0.5,
        height: 10,
        status: OperationalStatus.airborne,
        protocolVersion: 1,
        rawContent: Uint8List(0),
        altitudePressure: null,
        timestamp: const Duration(seconds: 20),
        altitudeGeodetic: null,
        baroAltitudeAccuracy: VerticalAccuracy.meters_150,
        timestampAccuracy: null,
      ),
      basicIdMessages: {
        IDType.serialNumber: BasicIDMessage(
          protocolVersion: 1,
          uasID: SerialNumber(serialNumber: '52426900931WDHW83'),
          rawContent: Uint8List(0),
          uaType: UAType.helicopterOrMultirotor,
        ),
      },
      operatorIdMessage: OperatorIDMessage(
        protocolVersion: 1,
        operatorID: 'FIN87astrdge12k8-xyz',
        rawContent: Uint8List(0),
        operatorIDType: OperatorIDTypeOperatorID(),
      ),
      selfIdMessage: SelfIDMessage(
        protocolVersion: 1,
        rawContent: Uint8List(0),
        description: 'This is very secret operation!',
        descriptionType: const DescriptionTypeText(),
      ),
    ),
  ];

  AircraftCubit({required this.expirationCubit})
      : super(AircraftState(packHistory: {}, dataAuthenticityStatuses: {})) {
    expirationCubit.deleteCallback = deletePack;
  }

  // timer used to notify UI
  void initEmitTimer({
    Duration duration = const Duration(
      milliseconds: uiUpdateIntervalMs,
    ),
  }) {
    stopEmitTimer();
    _refreshTimer = Timer.periodic(
      duration,
      (_) => aircraftUpdate,
    );
  }

  void aircraftUpdate() {
    emit(
      AircraftStateUpdate(
        packHistory: state.packHistory(),
        dataAuthenticityStatuses: state.dataAuthenticityStatuses,
      ),
    );
  }

  void stopEmitTimer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
  }

  MessageContainer? findByMacAddress(String mac) {
    return state.packHistory()[mac]?.last;
  }

  MessageContainer? findByUasID(String uasId) {
    final packs = state.packHistory().values.firstWhere(
        (packList) => packList.any(
              (element) => element.containsUasId(uasId),
            ),
        orElse: () => []);
    return packs.isEmpty ? null : packs.last;
  }

  List<MessageContainer>? packsForDevice(String mac) {
    return state.packHistory()[mac];
  }

  Future<void> clearAircraft() async {
    emit(
      AircraftStateUpdate(packHistory: {}, dataAuthenticityStatuses: {}),
    );
  }

  Future<void> addPack(MessageContainer pack) async {
    try {
      final data = state._packHistory;
      // new pack
      if (!data.containsKey(pack.macAddress)) {
        data[pack.macAddress] = [pack];
      } else {
        // update of already seen aircraft
        data[pack.macAddress]?.add(pack);
        // remove old and start new expiry timer
        expirationCubit.removeTimer(pack.macAddress);
      }
      expirationCubit.addTimer(pack.macAddress);
      emit(
        AircraftStateBuffering(
          packHistory: data,
          dataAuthenticityStatuses: state.dataAuthenticityStatuses
            ..addAll({
              pack.macAddress:
                  MessageContainerAuthenticator.determineAuthenticityStatus(
                pack,
              )
            }),
        ),
      );
    } on Exception {
      rethrow;
    }
  }

  String get showcaseDummyMac {
    return _packs[0].macAddress;
  }

  Future<MessageContainer?> addShowcaseDummyPack() async {
    await clearAircraft();
    final pack = _packs[0];
    try {
      final data = state.packHistory();
      data[pack.macAddress] = [pack];
      emit(
        AircraftStateUpdate(
          packHistory: data,
          dataAuthenticityStatuses: state.dataAuthenticityStatuses,
        ),
      );
    } on Exception {
      rethrow;
    }
    return pack;
  }

  Future<void> removeShowcaseDummyPack() async {
    final pack = _packs[0];
    await deletePack(pack.macAddress);
  }

  Future<void> deletePack(String mac) async {
    expirationCubit.removeTimer(mac);

    emit(
      AircraftStateUpdate(
        packHistory: state._packHistory..removeWhere((key, _) => mac == key),
        dataAuthenticityStatuses: state.dataAuthenticityStatuses
          ..removeWhere((key, _) => mac == key),
      ),
    );
  }

  void applyState(AircraftState state) {
    emit(state);
  }
}
