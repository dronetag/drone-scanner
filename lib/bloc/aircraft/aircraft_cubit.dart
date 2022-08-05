import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/csvlogger.dart';
import '../../utils/utils.dart';

class AircraftState {
  final Map<String, List<MessagePack>> _packHistory;
  final bool cleanOldPacks;
  final int cleanTimeSec;

  final Map<String, String> aircraftLabels;

  Map<String, List<MessagePack>> packHistory() {
    return _packHistory;
  }

  Map<String, List<MessagePack>> packHistoryByLastUpdate() {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (e1.value.last.lastUpdate.isBefore(e2.value.last.lastUpdate)) {
              return 1;
            }
            return -1;
          },
        ),
    );
  }

  Map<String, List<MessagePack>> packHistoryByUASID() {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (e1.value.last.basicIdMessage == null) return 1;
            if (e2.value.last.basicIdMessage == null) return -1;
            return e1.value.last.basicIdMessage!.uasId
                .compareTo(e2.value.last.basicIdMessage!.uasId);
          },
        ),
    );
  }

  Map<String, List<MessagePack>> packHistoryByDistance(LatLng userPos) {
    return Map.fromEntries(
      _packHistory.entries.toList()
        ..sort(
          (e1, e2) {
            if (e1.value.last.locationMessage == null ||
                e1.value.last.locationMessage?.latitude == null ||
                e1.value.last.locationMessage?.longitude == null) return 0;
            if (e2.value.last.locationMessage == null ||
                e2.value.last.locationMessage?.latitude == null ||
                e2.value.last.locationMessage?.longitude == null) return 0;

            final e1Dist = calculateDistance(
              e1.value.last.locationMessage!.latitude!,
              e1.value.last.locationMessage!.longitude!,
              userPos.latitude,
              userPos.longitude,
            );
            final e2Dist = calculateDistance(
              e2.value.last.locationMessage!.latitude!,
              e2.value.last.locationMessage!.longitude!,
              userPos.latitude,
              userPos.longitude,
            );
            if (e1Dist < e2Dist) {
              return -1;
            }
            return 1;
          },
        ),
    );
  }

  AircraftState(
      {required Map<String, List<MessagePack>> packHistory,
      required this.cleanOldPacks,
      required this.cleanTimeSec,
      required this.aircraftLabels})
      : _packHistory = packHistory;

  AircraftState copyWith({
    Map<String, List<MessagePack>>? packHistory,
    bool? cleanOldPacks,
    int? cleanTimeSec,
    Map<String, String>? aircraftLabels,
  }) =>
      AircraftState(
        packHistory: packHistory ?? _packHistory,
        cleanOldPacks: cleanOldPacks ?? this.cleanOldPacks,
        cleanTimeSec: cleanTimeSec ?? this.cleanTimeSec,
        aircraftLabels: aircraftLabels ?? this.aircraftLabels,
      );
}

class AircraftCubit extends Cubit<AircraftState> {
  final Map<String, Timer> _expiryTimers = {};
  AircraftState? stateMemento;
  // storage for user-given labels
  final LocalStorage storage = LocalStorage('dronescanner');

  // data for showcase
  final List<MessagePack> _packs = [
    MessagePack(
      macAddress: '00:00:5e:00:53:ae',
      lastUpdate: DateTime.now(),
      locationMessage: pigeon.LocationMessage(
        receivedTimestamp: DateTime.now().microsecondsSinceEpoch,
        macAddress: '00:00:5e:00:53:ae',
        latitude: 50.073058,
        heightType: pigeon.HeightType.Ground,
        direction: 1,
        speedAccuracy: pigeon.SpeedAccuracy.meter_per_second_0_3,
        verticalAccuracy: pigeon.VerticalAccuracy.meters_1,
        horizontalAccuracy: pigeon.HorizontalAccuracy.kilometers_18_52,
        speedHorizontal: 0.2,
        speedVertical: 0.5,
        longitude: 14.411540,
        height: 10,
        status: pigeon.AircraftStatus.Airborne,
        rssi: -100,
        source: pigeon.MessageSource.BluetoothLegacy,
      ),
      basicIdMessage: pigeon.BasicIdMessage(
        macAddress: '00:00:5e:00:53:ae',
        receivedTimestamp: DateTime.now().microsecondsSinceEpoch,
        uasId: '52426900931WDHW83',
        idType: pigeon.IdType.UTM_Assigned_ID,
        uaType: pigeon.UaType.Helicopter_or_Multirotor,
        rssi: -90,
        source: pigeon.MessageSource.BluetoothLegacy,
      ),
      operatorIdMessage: pigeon.OperatorIdMessage(
        macAddress: '00:00:5e:00:53:ae',
        receivedTimestamp: DateTime.now().microsecondsSinceEpoch,
        operatorId: 'CZE 345398739140810',
        rssi: -60,
        source: pigeon.MessageSource.BluetoothLegacy,
      ),
      selfIdMessage: pigeon.SelfIdMessage(
        macAddress: '00:00:5e:00:53:ae',
        receivedTimestamp: DateTime.now().microsecondsSinceEpoch,
        descriptionType: 0,
        operationDescription: 'This is very secret operation!',
      ),
    ),
  ];

  AircraftCubit()
      : super(AircraftState(
          packHistory: <String, List<MessagePack>>{},
          cleanOldPacks: false,
          cleanTimeSec: 100,
          aircraftLabels: <String, String>{},
        )) {
    fetchSavedLabels();
  }

  // load persistently saved settings
  Future<void> fetchSavedSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final cleanPacks = preferences.getBool('cleanOldPacks');
    if (cleanPacks == null) {
      emit(state.copyWith(cleanOldPacks: false));
    } else {
      emit(state.copyWith(cleanOldPacks: cleanPacks));
    }
    final cleanPacksSec = preferences.getInt('cleanTimeSec');
    if (cleanPacksSec == null) {
      emit(state.copyWith(cleanTimeSec: 100));
    } else {
      emit(state.copyWith(cleanTimeSec: cleanPacksSec));
    }
  }

  // labels are stored locally on device,
  Future<void> fetchSavedLabels() async {
    await storage.ready.then(
      (ready) {
        if (ready) {
          var labels = storage.getItem('labels');
          if (labels == null) {
            return;
          }
          final labelsMap = <String, String>{};
          (json.decode(labels as String) as Map<String, dynamic>)
              .forEach((key, value) => labelsMap[key] = value as String);
          emit(state.copyWith(aircraftLabels: labelsMap));
        }
      },
    );
  }

  // labels are stored locally on device,
  Future<void> addAircraftLabel(String mac, String label) async {
    var labels = state.aircraftLabels;
    labels[mac] = label;
    emit(state.copyWith(aircraftLabels: labels));
    await _saveLabels();
  }

  String? getAircraftLabel(String mac) {
    return state.aircraftLabels[mac];
  }

  Future<void> _saveLabels() async {
    await storage.setItem('labels', json.encode(state.aircraftLabels));
    await fetchSavedLabels();
  }

  Future<void> setCleanOldPacks({required bool clean}) async {
    // persistently save this settings
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('cleanOldPacks', clean);
    // cancel or restart expiry timers
    if (!clean) {
      _expiryTimers.forEach(
        (key, value) {
          value.cancel();
        },
      );
    } else {
      resetExpiryTimers();
    }
    emit(state.copyWith(cleanOldPacks: clean));
  }

  Future<void> setcleanTimeSec(int s) async {
    // persistently save this setting
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('cleanTimeSec', s);
    emit(state.copyWith(cleanTimeSec: s));
    if (!state.cleanOldPacks) return;
    resetExpiryTimers();
  }

  void resetExpiryTimers() {
    final toDelete = <String>[];
    state.packHistory().forEach((key, value) {
      if (state.packHistory()[key] == null ||
          state.packHistory()[key]!.isEmpty ||
          state.packHistory()[key]!.last.locationMessage == null) {
        return;
      }
      final lastTStamp =
          state.packHistory()[key]!.last.locationMessage!.receivedTimestamp;
      final packAgeSec =
          (DateTime.now().millisecondsSinceEpoch - lastTStamp) / 1000;
      final duration = state.cleanTimeSec - packAgeSec.toInt();
      if (duration <= 0) {
        toDelete.add(key);
        return;
      }
      if (_expiryTimers[key] != null) {
        _expiryTimers[key]?.cancel();
      }
      _expiryTimers[key] =
          Timer(Duration(seconds: state.cleanTimeSec - packAgeSec.toInt()), () {
        // remove if packs expire
        deletePack(key);
      });
    });
    for (final element in toDelete) {
      deletePack(element);
    }
  }

  MessagePack? findByMacAddress(String mac) {
    return state.packHistory()[mac]?.last;
  }

  List<MessagePack>? packsForDevice(String mac) {
    return state.packHistory()[mac];
  }

  Future<void> clear() async {
    emit(state.copyWith(packHistory: {}));
  }

  Future<void> addPack(MessagePack pack) async {
    try {
      // set received time
      pack.locationMessage?.receivedTimestamp =
          DateTime.now().millisecondsSinceEpoch;
      final data = state.packHistory();
      //
      if (!data.containsKey(pack.macAddress)) {
        data[pack.macAddress] = [pack];
      } else {
        data[pack.macAddress]?.add(pack);
        // restart expiry timer
        _expiryTimers[pack.macAddress]?.cancel();
      }
      if (state.cleanOldPacks) {
        _expiryTimers[pack.macAddress] = Timer(
          Duration(seconds: state.cleanTimeSec),
          () {
            // remove if packs expire
            deletePack(pack.macAddress);
          },
        );
      }
      //sortPacksByLastUpdate();
      emit(state.copyWith(packHistory: data));
    } on Exception {
      rethrow;
    }
  }

  String get showcaseDummyMac {
    return _packs[0].macAddress;
  }

  Future<MessagePack?> addShowcaseDummyPack() async {
    await clear();
    final pack = _packs[0];
    pack.locationMessage?.receivedTimestamp =
        DateTime.now().millisecondsSinceEpoch;
    try {
      final data = state.packHistory();
      data[pack.macAddress] = [pack];
      emit(state.copyWith(packHistory: data));
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
    if (_expiryTimers.containsKey(mac)) {
      _expiryTimers.remove(mac);
    }

    final data = state.packHistory();
    data.removeWhere((key, _) => mac == key);
    emit(state.copyWith(packHistory: data));
  }

  Future<void> exportPacksToCSV({required bool save}) async {
    await checkStoragePermission();
    var csv = '';
    state.packHistory().forEach((key, value) {
      final csvData = createCSV(value);
      csv += const ListToCsvConverter().convert(csvData);
    });
    if (save) {
      await _saveExportFile(csv, 'all');
    } else {
      await _shareExportFile(csv, 'all');
    }
  }

  Future<String> exportPackToCSV({
    required String mac,
    required bool save,
  }) async {
    if (state.packHistory()[mac] == null) return '';
    // request permission
    await checkStoragePermission();

    final csvData = createCSV(state.packHistory()[mac]!);

    final csv = const ListToCsvConverter().convert(csvData);

    /// Write to a file
    late final String uasId;
    if (state.packHistory()[mac]!.isNotEmpty &&
        state.packHistory()[mac]?.last.basicIdMessage != null &&
        state.packHistory()[mac]?.last.basicIdMessage?.uasId != null) {
      uasId = state.packHistory()[mac]!.last.basicIdMessage!.uasId;
    } else {
      uasId = mac;
    }
    String filePath;
    if (save) {
      filePath = await _saveExportFile(csv, uasId);
    } else {
      filePath = await _shareExportFile(csv, uasId);
    }
    return filePath;
  }

  Future<void> checkStoragePermission() async {
    final perm = await Permission.storage.isGranted;
    if (!perm) {
      await [
        Permission.storage,
      ].request();
    }
  }

  Future<String> _saveExportFile(String csv, String name) async {
    //general downloads folder (accessible by files app) ANDROID ONLY
    if (!Platform.isAndroid) {
      return '';
    }
    final generalDownloadDir = Directory('/storage/emulated/0/Download');
    final resultName = name.replaceAll(':', '-');
    final pathOfTheFileToWrite =
        '${generalDownloadDir.path}/csv_export$resultName.csv';
    var file = await File(pathOfTheFileToWrite).create();
    file = await file.writeAsString(csv);
    return pathOfTheFileToWrite.replaceAll(
      '/storage/emulated/0/Download',
      'Downloads',
    );
  }

  Future<String> _shareExportFile(String csv, String name) async {
    final directory = await getApplicationDocumentsDirectory();

    late final String pathOfTheFileToWrite;
    if (Platform.isAndroid) {
      pathOfTheFileToWrite = '${directory.path}/csv_export-$name.csv';
    } else {
      pathOfTheFileToWrite = '${directory.path}/csv_export.csv';
    }
    var file = File(pathOfTheFileToWrite);
    file = await file.writeAsString(csv);

    final result = await Share.shareFilesWithResult([pathOfTheFileToWrite],
        text: 'Your Data');
    if (result.status == ShareResultStatus.success) {
      return pathOfTheFileToWrite;
    } else {
      return '';
    }
  }

  void cacheCurrentState() {
    stateMemento = state.copyWith();
  }

  void applyCachedState() {
    if (stateMemento != null) emit(stateMemento!);
  }
}
