import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StandardsState {
  final bool androidSystem;
  final bool btLegacy; // bt4
  final bool btExtended; // bt5
  final bool wifiBeacon;
  final bool wifiNaN; // aware on android
  final bool btExtendedClaimed; // can be claimed but still not work
  // if adv len is < 1000, we stronly suspect Bt long range scanning wont work
  final int maxAdvDataLen;
  // permissions
  final bool btEnabled;
  final bool locationEnabled;
  final bool backgroundLocationEnabled;
  // true if user was asked about background location and cancelled request
  final bool backgroundLocationDenied;
  final bool notificationsEnabled;
  final bool internetAvailable;

  static const logPlatformStandardsKey = 'logPlatformStandards';
  static const backgroundLocationDeniedKey = 'backgroundLocationDenied';

  StandardsState({
    required this.androidSystem,
    required this.btLegacy,
    required this.btExtended,
    required this.wifiBeacon,
    required this.wifiNaN,
    required this.btExtendedClaimed,
    required this.maxAdvDataLen,
    required this.btEnabled,
    required this.locationEnabled,
    required this.backgroundLocationEnabled,
    required this.backgroundLocationDenied,
    required this.notificationsEnabled,
    required this.internetAvailable,
  });

  StandardsState copyWith({
    bool? androidSystem,
    bool? btLegacy,
    bool? btExtended,
    bool? wifiBeacon,
    bool? wifiNaN,
    bool? btExtendedClaimed,
    int? maxAdvDataLen,
    bool? btEnabled,
    bool? locationEnabled,
    bool? backgroundLocationEnabled,
    bool? backgroundLocationDenied,
    bool? notificationsEnabled,
    bool? internetAvailable,
  }) =>
      StandardsState(
        androidSystem: androidSystem ?? this.androidSystem,
        btLegacy: btLegacy ?? this.btLegacy,
        btExtended: btExtended ?? this.btExtended,
        wifiBeacon: wifiBeacon ?? this.wifiBeacon,
        wifiNaN: wifiNaN ?? this.wifiNaN,
        btExtendedClaimed: btExtendedClaimed ?? this.btExtendedClaimed,
        maxAdvDataLen: maxAdvDataLen ?? this.maxAdvDataLen,
        btEnabled: btEnabled ?? this.btEnabled,
        locationEnabled: locationEnabled ?? this.locationEnabled,
        backgroundLocationDenied:
            backgroundLocationDenied ?? this.backgroundLocationDenied,
        backgroundLocationEnabled:
            backgroundLocationEnabled ?? this.backgroundLocationEnabled,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        internetAvailable: internetAvailable ?? this.internetAvailable,
      );
}

class StandardsCubit extends Cubit<StandardsState> {
  StandardsCubit()
      : super(
          StandardsState(
            androidSystem: false,
            btLegacy: false,
            btExtended: false,
            wifiBeacon: false,
            wifiNaN: false,
            btExtendedClaimed: false,
            maxAdvDataLen: 0,
            btEnabled: false,
            internetAvailable: false,
            notificationsEnabled: false,
            locationEnabled: false,
            backgroundLocationEnabled: false,
            backgroundLocationDenied: false,
          ),
        );

  Future<void> fetchAndSetStandards() async {
    var androidSystem = false;
    var btLegacy = false;
    var btExtended = false;
    var wifiBeacon = false;
    var wifiNaN = false;
    var btExtendedClaimed = false;
    var maxAdvDataLen = 0;

    // always supported on android
    if (Platform.operatingSystem == 'android') {
      androidSystem = true;
      wifiBeacon = true;
      btLegacy = true;
    }
    // ios supports just bt legacy
    else if (Platform.operatingSystem == 'ios') {
      androidSystem = false;
      wifiBeacon = false;
      btLegacy = true;
    }
    btExtendedClaimed = await FlutterOpenDroneId.isBluetoothExtendedSupported;
    wifiNaN = await FlutterOpenDroneId.isWifiNanSupported;

    maxAdvDataLen = await FlutterOpenDroneId.btMaxAdvDataLen;
    // we suppose, that even though device claims nan support,
    // it wont work if maxadvdata len is lower than 1000
    if (btExtendedClaimed && maxAdvDataLen > 1000) {
      btExtended = true;
    } else {
      btExtended = false;
    }

    emit(
      state.copyWith(
        androidSystem: androidSystem,
        wifiBeacon: wifiBeacon,
        wifiNaN: wifiNaN,
        btLegacy: btLegacy,
        btExtended: btExtended,
        btExtendedClaimed: btExtendedClaimed,
        maxAdvDataLen: maxAdvDataLen,
      ),
    );

    final preferences = await SharedPreferences.getInstance();

    final backgroundLocationDenied =
        preferences.getBool(StandardsState.backgroundLocationDeniedKey) ??
            false;
    emit(state.copyWith(backgroundLocationDenied: backgroundLocationDenied));

    final logPlatformStatus =
        preferences.getBool(StandardsState.logPlatformStandardsKey);
    // skip if info was already logged
    if (logPlatformStatus != null && !logPlatformStatus) {
      return;
    }
    final platform = Platform.isAndroid ? 'Android' : 'iOS';
    var osVersion = Platform.operatingSystemVersion;
    String? phoneModel;
    String? phoneManufacturer;

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      phoneModel = androidInfo.model;
      phoneManufacturer = androidInfo.manufacturer;
      osVersion = '${androidInfo.version.release} $osVersion';
    } else {
      final iosInfo = await deviceInfo.iosInfo;
      phoneModel = iosInfo.name;
      phoneManufacturer = 'Apple';
    }
    // TODO: use this information
    Logger.root.info('phoneModel $phoneManufacturer $phoneModel');
    Logger.root.info('os $platform $osVersion');
    Logger.root.info('btLegacy $btLegacy');
    Logger.root.info('btExtended $btExtended');
    Logger.root.info('wifiBeacon $wifiBeacon');
    Logger.root.info('wifiNan $wifiNaN');
    Logger.root.info('maxAdvDataLen $maxAdvDataLen');

    // set that platforms standards were already logged
    await preferences.setBool(StandardsState.logPlatformStandardsKey, true);
  }

  void setLocationEnabled({required bool enabled}) =>
      emit(state.copyWith(locationEnabled: enabled));

  void setBackgroundLocationEnabled({required bool enabled}) async =>
      emit(state.copyWith(backgroundLocationEnabled: enabled));

  Future<void> setBackgroundLocationDenied() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(StandardsState.backgroundLocationDeniedKey, true);
    emit(state.copyWith(
        backgroundLocationEnabled: false, backgroundLocationDenied: true));
  }

  void setBluetoothEnabled({required bool enabled}) =>
      emit(state.copyWith(btEnabled: enabled));

  void setNotificationsEnabled({required bool enabled}) =>
      emit(state.copyWith(notificationsEnabled: enabled));

  void setInternetAvailable({required bool available}) =>
      emit(state.copyWith(internetAvailable: available));
}
