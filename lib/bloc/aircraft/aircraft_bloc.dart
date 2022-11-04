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

import '/utils/csvlogger.dart';
import '../../utils/utils.dart';
import 'aircraft_expiration_cubit.dart';

part 'aircraft_state.dart';
part 'aircraft_event.dart';

class AircraftBloc extends Bloc<AircraftEvent, AircraftState> {
  Timer? _refreshTimer;
  AircraftExpirationCubit expirationCubit;
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

  AircraftBloc(this.expirationCubit)
      : super(
          AircraftState(
            packHistory: <String, List<MessagePack>>{},
            aircraftLabels: <String, String>{},
          ),
        ) {
    expirationCubit.setDeleteCallback(deletePack);
    on<AircraftUpdate>((event, emit) {
      emit(
        AircraftStateUpdate(
            packHistory: event.packHistory,
            aircraftLabels: state.aircraftLabels),
      );
    });
    on<AircraftBuffering>((event, emit) {
      emit(
        AircraftStateBuffering(
          packHistory: event.packHistory,
          aircraftLabels: state.aircraftLabels,
        ),
      );
    });
    on<AircraftLabelsUpdate>(
      (event, emit) => emit(
        state.copyWith(
          aircraftLabels: event.labels,
        ),
      ),
    );

    on<AircraftApplyState>(
      (event, emit) => emit(event.state),
    );
    fetchSavedLabels();
  }

  // timer used to notify UI
  void initEmitTimer({Duration duration = const Duration(milliseconds: 500)}) {
    stopEmitTimer();
    _refreshTimer = Timer.periodic(
      duration,
      (_) {
        add(AircraftUpdate(state._packHistory));
      },
    );
  }

  void stopEmitTimer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
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
      add(AircraftLabelsUpdate(labelsMap));
    }
  }

  // Stores the label persistently locally on the device
  Future<void> addAircraftLabel(String mac, String label) async {
    var labels = state.aircraftLabels;
    labels[mac] = label;
    add(AircraftLabelsUpdate(labels));
    await _saveLabels();
  }

  // deletes locally stored label for aircraft with given mac
  Future<void> deleteAircraftLabel(String mac) async {
    var labels = state.aircraftLabels;
    labels.remove(mac);
    add(AircraftLabelsUpdate(labels));
    await _saveLabels();
  }

  String? getAircraftLabel(String mac) {
    return state.aircraftLabels[mac];
  }

  Future<void> _saveLabels() async {
    await storage.setItem('labels', json.encode(state.aircraftLabels));
    await fetchSavedLabels();
  }

  MessagePack? findByMacAddress(String mac) {
    return state.packHistory()[mac]?.last;
  }

  List<MessagePack>? packsForDevice(String mac) {
    return state.packHistory()[mac];
  }

  Future<void> clear() async {
    add(
      AircraftUpdate(
        {},
      ),
    );
  }

  Future<void> addPack(MessagePack pack) async {
    try {
      // set received time
      pack.locationMessage?.receivedTimestamp =
          DateTime.now().millisecondsSinceEpoch;
      final data = state._packHistory;
      // new pack
      if (!data.containsKey(pack.macAddress)) {
        data[pack.macAddress] = [pack];
      } else {
        // update of already seen aircraft
        data[pack.macAddress]?.add(pack);
        // restart expiry timer
        expirationCubit.restartTimer(pack.macAddress);
      }
      expirationCubit.addTimer(pack.macAddress);
      add(AircraftBuffering(data));
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
      add(
        AircraftUpdate(data),
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

    final data = state._packHistory;
    data.removeWhere((key, _) => mac == key);
    add(AircraftUpdate(data));
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

  void applyState(AircraftState state) {
    add(AircraftApplyState(state));
  }
}
