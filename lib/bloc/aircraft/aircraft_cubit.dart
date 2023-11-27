import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '/utils/csvlogger.dart';
import '../../models/aircraft_model_info.dart';
import '../../services/ornithology_rest_client.dart';
import '../../utils/utils.dart';
import '../sliders_cubit.dart';
import 'aircraft_expiration_cubit.dart';

part 'aircraft_state.dart';

class AircraftCubit extends Cubit<AircraftState> {
  Timer? _refreshTimer;
  final AircraftExpirationCubit expirationCubit;
  // storage for user-given labels
  final LocalStorage storage = LocalStorage('dronescanner');
  final OrnithologyRestClient ornithologyRestClient;

  static const uiUpdateIntervalMs = 200;
  static const _labelsKey = 'labels';
  static const _modelInfoKey = 'model_info';

  // data for showcase
  final List<MessageContainer> _packs = [
    MessageContainer(
      macAddress: '00:00:5e:00:53:ae',
      lastUpdate: DateTime.now(),
      lastMessageRssi: -100,
      source: pigeon.MessageSource.BluetoothLegacy,
      locationMessage: LocationMessage(
        location: Location(latitude: 50.073058, longitude: 14.411540),
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
        timestamp: Duration(seconds: 20),
        altitudeGeodetic: null,
        baroAltitudeAccuracy: VerticalAccuracy.meters_150,
        timestampAccuracy: null,
      ),
      basicIdMessage: BasicIDMessage(
        protocolVersion: 1,
        uasID: SerialNumber(serialNumber: '52426900931WDHW83'),
        rawContent: Uint8List(0),
        uaType: UAType.helicopterOrMultirotor,
      ),
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
        descriptionType: DescriptionTypeText(),
      ),
    ),
  ];

  AircraftCubit(
      {required this.expirationCubit, required this.ornithologyRestClient})
      : super(
          AircraftState(
            packHistory: <String, List<MessageContainer>>{},
            aircraftLabels: <String, String>{},
            aircraftModelInfo: <String, AircraftModelInfo>{},
            fetchInProgress: false,
          ),
        ) {
    expirationCubit.deleteCallback = deletePack;
    fetchSavedAircraftLabels();
    fetchSavedModelInfo();
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
        aircraftLabels: state.aircraftLabels,
        aircraftModelInfo: state.aircraftModelInfo,
        fetchInProgress: state.fetchInProgress,
      ),
    );
  }

  void stopEmitTimer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
  }

  //Retrieves the labels stored persistently locally on the device
  Future<void> fetchSavedAircraftLabels() async {
    final ready = await storage.ready;
    if (ready) {
      var labels = storage.getItem(_labelsKey);
      final labelsMap = <String, String>{};
      if (labels != null) {
        (json.decode(labels as String) as Map<String, dynamic>)
            .forEach((key, value) => labelsMap[key] = value as String);
      }
      emit(
        state.copyWith(
          aircraftLabels: labelsMap,
        ),
      );
    }
  }

  //Retrieves the model info stored persistently locally on the device
  Future<void> fetchSavedModelInfo() async {
    final ready = await storage.ready;
    if (ready) {
      var storedModelInfo = storage.getItem(_modelInfoKey);
      final modelInfo = <String, AircraftModelInfo>{};
      if (storedModelInfo != null) {
        (json.decode(storedModelInfo as String) as Map<String, dynamic>)
            .forEach((key, value) =>
                modelInfo[key] = AircraftModelInfo.fromJson(value));
      }
      emit(
        state.copyWith(
          aircraftModelInfo: modelInfo,
        ),
      );
    }
  }

  Future<void> fetchModelInfo(String serialNumber) async {
    emit(state.copyWith(fetchInProgress: true));
    final modelInfo = await ornithologyRestClient.fetchAircraftModelInfo(
        serialNumber: serialNumber);
    emit(
      state.copyWith(aircraftModelInfo: {
        ...state.aircraftModelInfo,
        serialNumber: modelInfo
      }, fetchInProgress: false),
    );
    await _saveModelInfo();
  }

  // Stores the label persistently locally on the device
  Future<void> addAircraftLabel(String mac, String label) async {
    var labels = state.aircraftLabels;
    labels[mac] = label;
    emit(
      state.copyWith(aircraftLabels: labels),
    );
    await _saveLabels();
  }

  // deletes locally stored label for aircraft with given mac
  Future<void> deleteAircraftLabel(String mac) async {
    var labels = state.aircraftLabels;
    labels.remove(mac);
    emit(
      state.copyWith(aircraftLabels: labels),
    );
    await _saveLabels();
  }

  String? getAircraftLabel(String mac) {
    return state.aircraftLabels[mac];
  }

  AircraftModelInfo? getModelInfo(String uasId) {
    return state.aircraftModelInfo[uasId];
  }

  MessageContainer? findByMacAddress(String mac) {
    return state.packHistory()[mac]?.last;
  }

  MessageContainer? findByUasID(String uasId) {
    final packs = state.packHistory().values.firstWhere(
        (packList) => packList.any(
            (element) => element.basicIdMessage?.uasID.asString() == uasId),
        orElse: () => []);
    return packs.isEmpty ? null : packs.last;
  }

  List<MessageContainer>? packsForDevice(String mac) {
    return state.packHistory()[mac];
  }

  Future<void> clearAircraft() async {
    emit(
      AircraftStateUpdate(
        packHistory: {},
        aircraftLabels: state.aircraftLabels,
        aircraftModelInfo: state.aircraftModelInfo,
        fetchInProgress: false,
      ),
    );
  }

  Future<void> clearModelInfo() async {
    final ready = await storage.ready;
    if (ready) {
      await storage.deleteItem(_modelInfoKey);
      emit(state.copyWith(aircraftModelInfo: {}));
    }
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
          aircraftLabels: state.aircraftLabels,
          aircraftModelInfo: state.aircraftModelInfo,
          fetchInProgress: state.fetchInProgress,
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
          aircraftLabels: state.aircraftLabels,
          aircraftModelInfo: state.aircraftModelInfo,
          fetchInProgress: state.fetchInProgress,
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

    final data = state._packHistory;
    data.removeWhere((key, _) => mac == key);
    emit(
      AircraftStateUpdate(
        packHistory: data,
        aircraftLabels: state.aircraftLabels,
        aircraftModelInfo: state.aircraftModelInfo,
        fetchInProgress: state.fetchInProgress,
      ),
    );
  }

  Future<bool> exportPacksToCSV() async {
    final hasPerm = await checkStoragePermission();
    if (!hasPerm) {
      return false;
    }
    var csv = '';
    state.packHistory().forEach((key, value) {
      final csvData = CSVLogger.createCSV(value, includeHeader: csv == '');
      csv += '\n';
      csv += const ListToCsvConverter().convert(csvData);
    });
    if (csv.isEmpty) return false;
    return await _shareExportFile(csv, 'all');
  }

  Future<bool> exportPackToCSV({
    required String mac,
  }) async {
    if (state.packHistory()[mac] == null) return false;
    // request permission
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) return false;

    final csvData = CSVLogger.createCSV(state.packHistory()[mac]!);
    final csv = const ListToCsvConverter().convert(csvData);
    if (csv.isEmpty) return false;

    /// Write to a file
    late final String uasId;
    if (state.packHistory()[mac]!.isNotEmpty &&
        state.packHistory()[mac]?.last.basicIdMessage?.uasID.asString() !=
            null) {
      uasId = state.packHistory()[mac]!.last.basicIdMessage!.uasID.asString()!;
    } else {
      uasId = mac;
    }
    return await _shareExportFile(csv, uasId);
  }

  Future<bool> checkStoragePermission() async {
    if (Platform.isIOS) {
      return _storagePermissionCheck();
    } else {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      // Since Android SDK 33, storage is not used
      if (androidInfo.version.sdkInt >= 33) {
        return await _mediaStoragePermissionCheck();
      } else {
        return await _storagePermissionCheck();
      }
    }
  }

  Future<void> _saveLabels() async =>
      await storage.setItem(_labelsKey, json.encode(state.aircraftLabels));

  Future<void> _saveModelInfo() async => await storage.setItem(
        _modelInfoKey,
        json.encode(
          state.aircraftModelInfo.map(
            (key, value) => MapEntry(key, value.toJson()),
          ),
        ),
      );

  Future<bool> _storagePermissionCheck() async {
    final storage = await Permission.storage.status.isGranted;
    if (!storage) {
      return await Permission.storage.request().isGranted;
    }
    return storage;
  }

  Future<bool> _mediaStoragePermissionCheck() async {
    var videos = await Permission.videos.status.isGranted;
    var photos = await Permission.photos.status.isGranted;
    if (!videos || !photos) {
      // request at once, will produce 1 dialog
      videos = await Permission.videos.request().isGranted;
      photos = await Permission.videos.request().isGranted;
    }
    return videos && photos;
  }

  Future<bool> _shareExportFile(String csv, String name) async {
    final directory = await getApplicationDocumentsDirectory();

    final pathOfTheFileToWrite =
        '${directory.path}/drone_scanner_export_$name.csv';
    var file = File(pathOfTheFileToWrite);
    file = await file.writeAsString(csv);

    late final result;
    if (Platform.isAndroid) {
      result = await Share.shareXFiles([XFile(pathOfTheFileToWrite)],
          subject: 'Drone Scanner Export', text: 'Your Remote ID Data');
    } else {
      result = await Share.shareXFiles([XFile(pathOfTheFileToWrite)]);
    }
    if (result.status == ShareResultStatus.success) {
      return true;
    } else {
      return false;
    }
  }

  void applyState(AircraftState state) {
    emit(state);
  }
}
