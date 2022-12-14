import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String scanPriorityPreferenceString() {
    if (scanPriority == pigeon.ScanPriority.Low) {
      return 'Low';
    }
    if (scanPriority == pigeon.ScanPriority.High) {
      return 'High';
    }
    return 'Unknown';
  }

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

class OpendroneIdCubit extends Cubit<ScanningState> {
  StreamSubscription? listener;
  StreamSubscription? btStateListener;
  StreamSubscription? wifiStateListener;
  MapCubit mapCubit;
  SelectedAircraftCubit selectedAircraftCubit;
  AircraftCubit aircraftCubit;

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
    final preference = preferences.getString('scanPriorityPreference');

    if (preference == null) {
      return;
    }
    await setScanPriorityPreference(preference);
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

  void scanCallback(MessagePack pack) {
    aircraftCubit.addPack(pack);
    if (mapCubit.state.lockOnPoint &&
        pack.macAddress == selectedAircraftCubit.state.selectedAircraftMac &&
        pack.locationValid()) {
      mapCubit.centerToLocDouble(
        pack.locationMessage!.latitude!,
        pack.locationMessage!.longitude!,
      );
    }
  }

  Future<void> start() async {
    if (state.usedTechnologies == UsedTechnologies.None) return;
    listener = FlutterOpenDroneId.allMessages
        .debounceTime(Duration(milliseconds: 100))
        .listen(scanCallback);
    aircraftCubit.initEmitTimer();
    unawaited(FlutterOpenDroneId.startScan(state.usedTechnologies));
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

  Future<void> setBtUsed({required bool btUsed}) async {
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
    emit(state.copyWith(usedTechnologies: usedT));
    if (restart) {
      await start();
    }
  }

  Future<void> setWifiUsed({required bool wifiUsed}) async {
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
    emit(state.copyWith(usedTechnologies: usedT));
    initBtListener();
    if (restart) {
      await start();
    }
  }

  Future<void> setScanPriorityPreference(String preference) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('scanPriorityPreference', preference);

    pigeon.ScanPriority pref;
    if (preference == 'High') {
      pref = pigeon.ScanPriority.High;
    } else if (preference == 'Low') {
      pref = pigeon.ScanPriority.Low;
    } else {
      return;
    }
    emit(state.copyWith(scanPriority: pref));
  }
}
