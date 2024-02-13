import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/models/permissions_missing_exception.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/snackbar_messages.dart';
import 'aircraft/aircraft_cubit.dart';
import 'aircraft/selected_aircraft_cubit.dart';
import 'map/map_cubit.dart';

class ScanningState {
  bool isScanningWifi;
  bool isScanningBluetooth;
  UsedTechnologies usedTechnologies;
  pigeon.ScanPriority scanPriority;

  ScanningState({
    required this.isScanningWifi,
    required this.isScanningBluetooth,
    required this.usedTechnologies,
    required this.scanPriority,
  });

  ScanningState copyWith(
          {bool? isScanningWifi,
          bool? isScanningBluetooth,
          UsedTechnologies? usedTechnologies,
          pigeon.ScanPriority? scanPriority}) =>
      ScanningState(
        isScanningBluetooth: isScanningBluetooth ?? this.isScanningBluetooth,
        isScanningWifi: isScanningWifi ?? this.isScanningWifi,
        usedTechnologies: usedTechnologies ?? this.usedTechnologies,
        scanPriority: scanPriority ?? this.scanPriority,
      );
}

class SetScanResult {
  final bool success;
  final String? error;

  SetScanResult({required this.success, this.error});
}

class OpendroneIdCubit extends Cubit<ScanningState> {
  StreamSubscription? listener;
  StreamSubscription? btStateListener;
  StreamSubscription? wifiStateListener;
  MapCubit mapCubit;
  SelectedAircraftCubit selectedAircraftCubit;
  AircraftCubit aircraftCubit;

  static const messageDebounceMs = 50;

  OpendroneIdCubit({
    required this.mapCubit,
    required this.selectedAircraftCubit,
    required this.aircraftCubit,
  }) : super(
          ScanningState(
            isScanningBluetooth: false,
            isScanningWifi: false,
            usedTechnologies: UsedTechnologies.None,
            scanPriority: pigeon.ScanPriority.High,
          ),
        ) {
    initBtListener();
    initWifiListener();
    fetchAndSetPreference();
  }

  Future<void> fetchAndSetPreference() async {
    final preferences = await SharedPreferences.getInstance();
    final priorityOrdinal = preferences.getInt('scanPriorityPreference');

    if (priorityOrdinal == null) {
      return;
    }
    if (priorityOrdinal >= 0 &&
        priorityOrdinal < pigeon.ScanPriority.values.length) {
      await setScanPriorityPreference(
          pigeon.ScanPriority.values[priorityOrdinal]);
    }
  }

  void initWifiListener() {
    wifiStateListener = FlutterOpenDroneId.wifiState.listen(
      (scanning) => wifiStateCallback(
        isScanning: scanning,
      ),
    );
  }

  void initBtListener() =>
      btStateListener = FlutterOpenDroneId.bluetoothState.listen(
        (scanning) => btStateCallback(
          isScanning: scanning,
        ),
      );

  void cancelListener() {
    listener?.cancel();
    btStateListener?.cancel();
    wifiStateListener?.cancel();
  }

  void btStateCallback({required bool isScanning}) {
    // refresh ui just when state changes
    if (isScanning == state.isScanningBluetooth) {
      return;
    }
    emit(
      state.copyWith(isScanningBluetooth: isScanning),
    );
  }

  void wifiStateCallback({required bool isScanning}) {
    // refresh ui just when state changes
    if (isScanning == state.isScanningWifi) {
      return;
    }
    emit(
      state.copyWith(isScanningWifi: isScanning),
    );
  }

  void scanCallback(MessageContainer pack) {
    aircraftCubit.addPack(pack);
    if (mapCubit.state.lockOnPoint &&
        pack.macAddress == selectedAircraftCubit.state.selectedAircraftMac &&
        pack.locationValid) {
      mapCubit.centerToLocDouble(
        pack.locationMessage!.location!.latitude,
        pack.locationMessage!.location!.longitude,
      );
    }
  }

  Future<SetScanResult> start(UsedTechnologies usedTechnology) async {
    try {
      await FlutterOpenDroneId.startScan(usedTechnology);
      listener = FlutterOpenDroneId.allMessages
          .debounceTime(const Duration(milliseconds: messageDebounceMs))
          .listen(scanCallback);
      aircraftCubit.initEmitTimer();
    } on PermissionsMissingException catch (e) {
      return SetScanResult(
          success: false,
          error: getMissingPermissionsMessage(e.missingPermissions));
    }
    return SetScanResult(success: true);
  }

  Future<bool> isBtTurnedOn() async {
    return FlutterOpenDroneId.btTurnedOn;
  }

  Future<bool> isWifiTurnedOn() async {
    return FlutterOpenDroneId.wifiTurnedOn;
  }

  Future<void> stop() async {
    await listener?.cancel();
    aircraftCubit.stopEmitTimer();
    unawaited(FlutterOpenDroneId.stopScan());
  }

  Future<SetScanResult> setBtUsed({required bool btUsed}) async {
    var restart = false;
    var usedT = state.usedTechnologies;
    // cancel wifi subscription to avoid receiving events
    // until restart is complete
    await wifiStateListener?.cancel();
    // turning on bt, if wifi was active, restart scans
    if (btUsed) {
      if (state.usedTechnologies != UsedTechnologies.Wifi) {
        usedT = UsedTechnologies.Bluetooth;
      } else {
        usedT = UsedTechnologies.Both;
      }
      if (state.isScanningWifi) await FlutterOpenDroneId.stopScan();
      restart = true;
    }
    // turning off Bt, if wifi is still active, restart scans
    else {
      if (state.usedTechnologies == UsedTechnologies.Wifi ||
          state.usedTechnologies == UsedTechnologies.Both) {
        if (state.isScanningWifi) {
          await FlutterOpenDroneId.stopScan();
          restart = true;
        }
        usedT = UsedTechnologies.Wifi;
      } else {
        await stop();
        usedT = UsedTechnologies.None;
      }
    }
    initWifiListener();
    if (restart) {
      final res = await start(usedT);
      if (res.success) emit(state.copyWith(usedTechnologies: usedT));
      return res;
    }
    emit(state.copyWith(usedTechnologies: usedT));
    return SetScanResult(success: true);
  }

  Future<SetScanResult> setWifiUsed({required bool wifiUsed}) async {
    var restart = false;
    var usedT = state.usedTechnologies;
    await btStateListener?.cancel();
    // turning on Wifi, if bt was active, restart scans
    if (wifiUsed) {
      if (state.usedTechnologies != UsedTechnologies.Bluetooth) {
        usedT = UsedTechnologies.Wifi;
      } else {
        usedT = UsedTechnologies.Both;
      }
      if (state.isScanningBluetooth) await FlutterOpenDroneId.stopScan();
      restart = true;
    }
    // turning off Wifi, if bt is still active, restart scans
    else {
      if (state.usedTechnologies == UsedTechnologies.Bluetooth ||
          state.usedTechnologies == UsedTechnologies.Both) {
        if (state.isScanningBluetooth) {
          await FlutterOpenDroneId.stopScan();
          restart = true;
        }
        usedT = UsedTechnologies.Bluetooth;
      } else {
        await stop();
        usedT = UsedTechnologies.None;
      }
    }
    initBtListener();
    if (restart) {
      final res = await start(usedT);
      if (res.success) {
        emit(state.copyWith(usedTechnologies: usedT));
      } else {
        emit(state);
      }
      return res;
    }
    emit(state.copyWith(usedTechnologies: usedT));
    return SetScanResult(success: true);
  }

  Future<void> setScanPriorityPreference(pigeon.ScanPriority priority) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('scanPriorityPreference', priority.index);

    await FlutterOpenDroneId.setBtScanPriority(priority);
    emit(state.copyWith(scanPriority: priority));
  }
}
