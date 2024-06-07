import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../models/unit_value.dart';
import '../services/unit_conversion_service.dart';
import 'utils.dart';

class CSVLogger {
  static const locationFields = 15;
  static const basicFields = 3;
  static const operatorFields = 1;
  static const authFields = 0;
  static const selfIdFields = 2;
  static const systemFields = 11;

  final String distanceUnit;
  final String distanceSubUnit;
  final String altitudeUnit;
  final String speedUnit;

  final UnitsConversionService unitsConversion = UnitsConversionService();

  CSVLogger({
    required this.distanceUnit,
    required this.distanceSubUnit,
    required this.altitudeUnit,
    required this.speedUnit,
  });

  List<List<dynamic>> createCSV(List<MessageContainer> list,
      {bool includeHeader = true}) {
    final csvData = <List<dynamic>>[];
    if (includeHeader) csvData.add(_createCSVHeader());
    for (var i = 0; i < list.length; ++i) {
      csvData.addAll(_logMessagesInContainer(list[i]));
    }
    return csvData;
  }

  void _addEmptyFields(List<dynamic> list, int numFields) {
    for (var i = 0; i < numFields; ++i) {
      list.add('');
    }
  }

  String? _logMessageSource(MessageSource? type) =>
      type?.toString().replaceAll('MessageSource.', '');

  List<dynamic> _logLocationMessage(LocationMessage loc) {
    final row = <dynamic>[];
    row.add(loc.status.asString() ?? '');
    row.add(loc.location?.latitude ?? '');
    row.add(loc.location?.longitude ?? '');
    row.add(directionAsString(loc.direction?.toDouble()));
    row.add(unitsConversion
            .odidSpeedHorToCurrentUnit(loc.horizontalSpeed, speedUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidSpeedHorToCurrentUnit(loc.verticalSpeed, speedUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(loc.altitudePressure, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(loc.altitudeGeodetic, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(loc.height, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(loc.heightType.asString() ?? '');
    row.add(
      unitsConversion
              .odidHorizontalAccuracyToCurrentUnit(
                  loc.horizontalAccuracy, distanceUnit)
              ?.roundedValue(3) ??
          '',
    );
    row.add(unitsConversion
            .odidVerticalAccuracyToCurrentUnit(
                loc.verticalAccuracy, distanceUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidVerticalAccuracyToCurrentUnit(
                loc.baroAltitudeAccuracy, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidSpeedAccuracyToCurrentUnit(loc.speedAccuracy, speedUnit)
            ?.roundedValue(3) ??
        '');
    row.add(timeAccuracyToString(loc.timestampAccuracy));
    _addEmptyFields(
      row,
      basicFields + operatorFields + authFields + selfIdFields + systemFields,
    );
    return row;
  }

  List<dynamic> _logBasicMessage(BasicIDMessage message) {
    final row = <dynamic>[];
    _addEmptyFields(row, locationFields);
    row.add(message.uasID.type.asString() ?? '');
    row.add(message.uaType.asString() ?? '');
    row.add(message.uasID.asString());
    _addEmptyFields(
      row,
      operatorFields + authFields + selfIdFields + systemFields,
    );
    return row;
  }

  List<dynamic> _logOperatorMessage(OperatorIDMessage message) {
    final row = <dynamic>[];
    _addEmptyFields(row, locationFields + basicFields);

    row.add(message.operatorID != OPERATOR_ID_NOT_SET
        ? message.operatorID
        : 'Unknown');
    _addEmptyFields(
      row,
      authFields + selfIdFields + systemFields,
    );
    return row;
  }

  // TODO: implement
  List<dynamic> _logAuthMessage(AuthMessage message) {
    final row = <dynamic>[];
    _addEmptyFields(
        row,
        locationFields +
            basicFields +
            operatorFields +
            selfIdFields +
            systemFields);
    return row;
  }

  List<dynamic> _logSelfIdMessage(SelfIDMessage message) {
    final row = <dynamic>[];
    _addEmptyFields(
        row, locationFields + basicFields + operatorFields + authFields);
    row.add(message.descriptionType);
    row.add(message.description);
    _addEmptyFields(
      row,
      systemFields,
    );
    return row;
  }

  List<dynamic> _logSystemDataMessage(SystemMessage message) {
    final row = <dynamic>[];
    _addEmptyFields(
        row,
        locationFields +
            basicFields +
            operatorFields +
            authFields +
            selfIdFields);
    row.add(
      message.operatorLocationType.asString() ?? '',
    );
    row.add(message.operatorLocation?.latitude ?? '');
    row.add(message.operatorLocation?.longitude ?? '');
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(message.operatorAltitude, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(message.areaCount);
    row.add(unitsConversion
        .distanceDefaultToCurrent(
            UnitValue.meters(message.areaRadius), distanceUnit)
        .roundedValue(3));
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(message.areaCeiling, altitudeUnit)
            ?.roundedValue(3) ??
        '');
    row.add(unitsConversion
            .odidAltitudeToCurrentUnit(message.areaFloor, distanceUnit)
            ?.roundedValue(3) ??
        '');
    row.add(message.uaClassification
        .toString()
        .replaceAll('UAClassification.', ''));
    row.add(message.uaClassification.uaCategoryEuropeString() ?? '');
    row.add(message.uaClassification.uaClassEuropeString() ?? '');
    return row;
  }

  List<dynamic> _logMetadata(MessageContainer container, String messageType) {
    final row = <dynamic>[];
    row.add(messageType);
    row.add(_logMessageSource(container.source) ?? 'Unknown');
    row.add(container.lastUpdate);
    row.add(container.macAddress);
    return row;
  }

  List<List<dynamic>> _logMessagesInContainer(MessageContainer container) {
    final csvData = <List<dynamic>>[];
    if (container.locationMessage != null) {
      final row = _logMetadata(container, 'Location');
      row.addAll(_logLocationMessage(container.locationMessage!));
      csvData.add(row);
    }
    if (container.basicIdMessages != null) {
      for (final basicIdMessage in container.basicIdMessages!.values) {
        final row = _logMetadata(container, 'Basic ID');
        row.addAll(_logBasicMessage(basicIdMessage));
        csvData.add(row);
      }
    }
    if (container.operatorIdMessage != null) {
      final row = _logMetadata(container, 'Operator ID');
      row.addAll(_logOperatorMessage(container.operatorIdMessage!));
      csvData.add(row);
    }
    if (container.selfIdMessage != null) {
      final row = _logMetadata(container, 'Self ID');
      row.addAll(_logSelfIdMessage(container.selfIdMessage!));
      csvData.add(row);
    }
    if (container.authenticationMessage != null) {
      final row = _logMetadata(container, 'Authentication');
      row.addAll(_logAuthMessage(container.authenticationMessage!));
      csvData.add(row);
    }
    if (container.systemDataMessage != null) {
      final row = _logMetadata(container, 'System Data');
      row.addAll(_logSystemDataMessage(container.systemDataMessage!));
      csvData.add(row);
    }
    return csvData;
  }

  List<String> _createCSVHeader() => [
        // common
        'Message Type',
        'Message Source',
        'Timestamp',
        'Mac Address',
        // location
        'Status',
        'Latitude',
        'Longitude',
        'Direction',
        'Speed Horizontal ($speedUnit)',
        'Speed Vertical ($speedUnit)',
        'Altitude Pressure ($altitudeUnit)',
        'Altitude Geodetic ($altitudeUnit)',
        'Height ($altitudeUnit)',
        'Height Type ($altitudeUnit)',
        'Horizontal Accuracy ($distanceSubUnit)',
        'Vertical Accuracy ($distanceSubUnit)',
        'Baro Accuracy ($distanceSubUnit)',
        'Speed Accuracy ($speedUnit)',
        'Time Accuracy',
        // basic
        'ID Type',
        'UA Type',
        'UAS ID',
        // op ID
        'Operator ID',
        // self ID
        'Description Type',
        'Description',
        // system
        'Operator Location Type',
        'Operator Latitude',
        'Operator Longitude',
        'Operator Altitude Geo ($altitudeUnit)',
        'Area Count',
        'Area Radius ($distanceSubUnit)',
        'Area Ceiling ($altitudeUnit)',
        'Area Floor ($altitudeUnit)',
        'Classification Type',
        'Category',
        'Class Value',
      ];
}
