import 'dart:io';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/unit_conversion_service.dart';
import '../../utils/csvlogger.dart';
import '../../utils/gpxlogger.dart';
import '../units_settings_cubit.dart';
import 'aircraft_cubit.dart';

enum ExportFormat {
  csv,
  gpx,
}

class ExportState {}

class ExportCubit extends Cubit<ExportState> {
  final AircraftCubit aircraftCubit;
  final UnitsSettingsCubit unitsSettingsCubit;
  final UnitsConversionService unitsConversion;

  ExportCubit({
    required this.aircraftCubit,
    required this.unitsSettingsCubit,
    required this.unitsConversion,
  }) : super(ExportState());

  Future<bool> exportAllPacksToCSV() async {
    final hasPerm = await checkStoragePermission();
    if (!hasPerm) {
      return false;
    }
    var data = '';
    aircraftCubit.state.packHistory().forEach((key, value) {
      data += _createCSV(includeHeader: data == '', packs: value);
      data += '\n';
    });
    if (data.isEmpty) return false;
    return await _shareExportFile(
        format: ExportFormat.csv, data: data, name: 'all');
  }

  Future<bool> exportPack({
    required ExportFormat format,
    required String mac,
  }) async {
    final aircraftState = aircraftCubit.state;
    if (aircraftState.packHistory()[mac] == null) return false;
    // request permission
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) return false;

    String? data;
    if (format == ExportFormat.csv) {
      data = _createCSV(
          includeHeader: true, packs: aircraftState.packHistory()[mac]!);
    } else if (format == ExportFormat.gpx) {
      data = GPXLogger.createGPX(aircraftState.packHistory()[mac]!);
    }
    if (data == null || data.isEmpty) return false;

    return await _shareExportFile(
        format: format, data: data, name: _createFilename(mac));
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

  String _createCSV(
      {required bool includeHeader, required List<MessageContainer> packs}) {
    final logger = CSVLogger(
      distanceUnit: unitsSettingsCubit.state.exportDistanceUnit,
      distanceSubUnit: unitsSettingsCubit.state.exportDistanceSubUnit,
      altitudeUnit: unitsSettingsCubit.state.exportAltitudeUnit,
      speedUnit: unitsSettingsCubit.state.exportSpeedUnit,
      unitsConversion: unitsConversion,
    );

    return const ListToCsvConverter()
        .convert(logger.createCSV(packs, includeHeader: includeHeader));
  }

  // create filename from uasID or mac plus timestamp
  String _createFilename(String mac) {
    final aircraftState = aircraftCubit.state;

    late final String aircraftIdentifier;
    if (aircraftState.packHistory()[mac]!.isNotEmpty &&
        aircraftState
                .packHistory()[mac]
                ?.last
                .preferredBasicIdMessage
                ?.uasID
                .asString() !=
            null) {
      aircraftIdentifier = aircraftState
          .packHistory()[mac]!
          .last
          .preferredBasicIdMessage!
          .uasID
          .asString()!;
    } else {
      aircraftIdentifier = mac;
    }
    // replace delimiters with dash and remove milliseconds
    final timestampString =
        DateTime.now().toLocal().toString().replaceAll(RegExp(r'[ :.]'), '-');
    final timestampWithoutMs =
        timestampString.substring(0, timestampString.lastIndexOf('-'));

    return '$aircraftIdentifier-$timestampWithoutMs';
  }

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

  Future<bool> _shareExportFile(
      {required ExportFormat format,
      required String data,
      required String name}) async {
    final directory = await getApplicationDocumentsDirectory();
    final suffix = format == ExportFormat.csv ? 'csv' : 'gpx';

    final pathOfTheFileToWrite =
        '${directory.path}/drone_scanner_export_$name.$suffix';
    var file = File(pathOfTheFileToWrite);
    file = await file.writeAsString(data);

    late final ShareResult result;
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
}
