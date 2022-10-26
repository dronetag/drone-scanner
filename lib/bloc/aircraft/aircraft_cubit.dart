import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

part 'aircraft_state.dart';

class AircraftCubit extends Cubit<AircraftState> {
  Map<String, List<MessagePack>> packHistoryBuffer = {};
  Timer? _refreshTimer;
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
            cleanTimeSec: 60.0,
            aircraftLabels: <String, String>{},
            expiryTimers: {})) {
    fetchSavedLabels();
  }

  // timer used to notify UI
  void initEmitTimer({Duration duration = const Duration(milliseconds: 500)}) {
    stopEmitTimer();
    _refreshTimer = Timer.periodic(
      duration,
      (_) {
        emit(state.copyWith(packHistory: packHistoryBuffer));
      },
    );
  }

  void stopEmitTimer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
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
    final cleanPacksSec = preferences.getDouble('cleanTimeSec');
    if (cleanPacksSec == null) {
      emit(state.copyWith(cleanTimeSec: 60));
    } else {
      emit(state.copyWith(cleanTimeSec: cleanPacksSec));
    }
  }

  //Retrieves the labels stored persistently locally on the device
  Future<void> fetchSavedLabels() async {
    final ready = await storage.ready;
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
  }

  // Stores the label persistently locally on the device
  Future<void> addAircraftLabel(String mac, String label) async {
    var labels = state.aircraftLabels;
    labels[mac] = label;
    emit(state.copyWith(aircraftLabels: labels));
    await _saveLabels();
  }

  // deletes locally stored label for aircraft with given mac
  Future<void> deleteAircraftLabel(String mac) async {
    var labels = state.aircraftLabels;
    labels.remove(mac);
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
      final timers = state.expiryTimers;
      timers.forEach(
        (key, value) {
          value.cancel();
        },
      );
      emit(state.copyWith(cleanOldPacks: clean, expiryTimers: timers));
    } else {
      emit(state.copyWith(cleanOldPacks: clean));
      resetExpiryTimers();
    }
  }

  Future<void> setcleanTimeSec(double s) async {
    // persistently save this setting
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('cleanTimeSec', s);
    emit(state.copyWith(cleanTimeSec: s));
    if (!state.cleanOldPacks) return;
    resetExpiryTimers();
  }

  void resetExpiryTimers() {
    var timers = state.expiryTimers;
    final toDelete = <String>[];
    packHistoryBuffer.forEach((key, value) {
      if (packHistoryBuffer[key] == null ||
          packHistoryBuffer[key]!.isEmpty ||
          packHistoryBuffer[key]!.last.locationMessage == null) {
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
      if (timers[key] != null) {
        timers[key]?.cancel();
      }
      timers[key] = Timer(
          Duration(seconds: state.cleanTimeSec.toInt() - packAgeSec.toInt()),
          () {
        // remove if packs expire
        deletePack(key);
      });
    });
    for (final element in toDelete) {
      deletePack(element);
    }
    emit(
      state.copyWith(
        packHistory: packHistoryBuffer,
        expiryTimers: timers,
      ),
    );
  }

  MessagePack? findByMacAddress(String mac) {
    return state.packHistory()[mac]?.last;
  }

  List<MessagePack>? packsForDevice(String mac) {
    return state.packHistory()[mac];
  }

  Future<void> clear() async {
    packHistoryBuffer = {};
    emit(state.copyWith(packHistory: packHistoryBuffer));
  }

  Future<void> addPack(MessagePack pack) async {
    try {
      // set received time
      pack.locationMessage?.receivedTimestamp =
          DateTime.now().millisecondsSinceEpoch;
      final data = packHistoryBuffer;
      //
      if (!data.containsKey(pack.macAddress)) {
        data[pack.macAddress] = [pack];
      } else {
        data[pack.macAddress]?.add(pack);
        // restart expiry timer
        final timers = state.expiryTimers;
        timers[pack.macAddress]?.cancel();
        emit(state.copyWith(expiryTimers: timers));
      }
      if (state.cleanOldPacks) {
        final timers = state.expiryTimers;
        timers[pack.macAddress] = Timer(
          Duration(seconds: state.cleanTimeSec.toInt()),
          () {
            // remove if packs expire
            deletePack(pack.macAddress);
          },
        );
        emit(state.copyWith(expiryTimers: timers));
      }
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
    final timers = state.expiryTimers;
    if (timers.containsKey(mac)) {
      timers.remove(mac);
    }

    final data = packHistoryBuffer;
    data.removeWhere((key, _) => mac == key);
    emit(
      state.copyWith(packHistory: data, expiryTimers: timers),
    );
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
