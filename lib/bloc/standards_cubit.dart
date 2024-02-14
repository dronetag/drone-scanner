import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StandardsState {
  bool androidSystem = false;
  bool btLegacy = false; // bt4
  bool btExtended = false; // bt4
  bool wifiBeacon = false;
  bool wifiNaN = false; // aware on android
  bool btExtendedClaimed = false; // can be claimed but still not work
  // if adv len is < 1000, we stronly suspect Bt long range scanning wont work
  int maxAdvDataLen = 0;
  // permissions
  bool btEnabled = false;
  bool locationEnabled = false;
  bool notificationsEnabled = false;
  bool internetAvailable = false;

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
    final logPlatformStatus = preferences.getBool('logPlatformStandards');
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
    print('phoneModel $phoneManufacturer $phoneModel');
    print('os $platform $osVersion');
    print('btLegacy $btLegacy');
    print('btExtended $btExtended');
    print('wifiBeacon $wifiBeacon');
    print('wifiNan $wifiNaN');
    print('maxAdvDataLen $maxAdvDataLen');

    // set that platforms standards were already logged
    await preferences.setBool('logPlatformStandards', true);
  }

  Future<void> setLocationEnabled({required bool enabled}) async {
    emit(state.copyWith(locationEnabled: enabled));
  }

  Future<void> setBluetoothEnabled({required bool enabled}) async {
    emit(state.copyWith(btEnabled: enabled));
  }

  Future<void> setNotificationsEnabled({required bool enabled}) async {
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setInternetAvailable({required bool available}) async {
    emit(state.copyWith(internetAvailable: available));
  }
}
