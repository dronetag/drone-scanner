import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import 'utils.dart';

class CSVLogger {
  static const locationFields = 15;
  static const basicFields = 3;
  static const operatorFields = 1;
  static const authFields = 0;
  static const selfIdFields = 2;
  static const systemFields = 11;
  static final commonHeader = <dynamic>[
    // common
    'Message Type',
    'Message Source',
    'Timestamp',
    'Mac Address',
    // location
    'Status',
    'Latitide',
    'Logitude',
    'Direction',
    'Speed Horizontal',
    'Speed Vertical',
    'Altitude Pressure',
    'Altitude Geodetic',
    'Height',
    'Height Type',
    'Horizontal Accuracy',
    'Vertical Accuracy',
    'Baro Accuracy',
    'Speed Accuracy',
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
    'Operator Altitude Geo',
    'Are Count',
    'Area Radius',
    'Area Ceiling',
    'Area Floor',
    'Classification Type',
    'Category',
    'Class Value',
  ];

  static List<List<dynamic>> createCSV(List<MessageContainer> list,
      {bool includeHeader = true}) {
    final csvData = <List<dynamic>>[];
    if (includeHeader) csvData.add(commonHeader);
    for (var i = 0; i < list.length; ++i) {
      csvData.addAll(_logMessagesInContainer(list[i]));
    }
    return csvData;
  }

  static void _addEmptyFields(List<dynamic> list, int numFields) {
    for (var i = 0; i < numFields; ++i) {
      list.add('');
    }
  }

  static String? _logMessageSource(MessageSource? type) =>
      type?.toString().replaceAll('MessageSource.', '');

  static List<dynamic> _logLocationMessage(LocationMessage loc) {
    final row = <dynamic>[];
    row.add(loc.status.asString() ?? '');
    row.add(loc.location?.latitude ?? '');
    row.add(loc.location?.longitude ?? '');
    row.add(directionAsString(loc.direction?.toDouble()));
    row.add(getSpeedHorAsString(loc.horizontalSpeed));
    row.add(getSpeedHorAsString(loc.verticalSpeed));
    row.add(getAltitudeAsString(loc.altitudePressure));
    row.add(getAltitudeAsString(loc.altitudeGeodetic));
    row.add(getAltitudeAsString(loc.height));
    row.add(loc.heightType.asString() ?? '');
    row.add(
      horizontalAccuracyToString(loc.horizontalAccuracy),
    );
    row.add(
      verticalAccuracyToString(loc.verticalAccuracy),
    );
    row.add(verticalAccuracyToString(loc.baroAltitudeAccuracy));
    row.add(speedAccuracyToString(loc.speedAccuracy));
    row.add(timeAccuracyToString(loc.timestampAccuracy));
    _addEmptyFields(
      row,
      basicFields + operatorFields + authFields + selfIdFields + systemFields,
    );
    return row;
  }

  static List<dynamic> _logBasicMessage(BasicIDMessage message) {
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

  static List<dynamic> _logOperatorMessage(OperatorIDMessage message) {
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
  static List<dynamic> _logAuthMessage(AuthMessage message) {
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

  static List<dynamic> _logSelfIdMessage(SelfIDMessage message) {
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

  static List<dynamic> _logSystemDataMessage(SystemMessage message) {
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
    row.add(getAltitudeAsString(message.operatorAltitude));
    row.add(message.areaCount);
    row.add(message.areaRadius);
    row.add(getAltitudeAsString(message.areaCeiling));
    row.add(getAltitudeAsString(message.areaFloor));
    row.add(message.uaClassification
        .toString()
        .replaceAll('UAClassification.', ''));
    row.add(message.uaClassification.uaCategoryEuropeString() ?? '');
    row.add(message.uaClassification.uaClassEuropeString() ?? '');
    return row;
  }

  static List<dynamic> logMetadata(
      MessageContainer container, String messageType) {
    final row = <dynamic>[];
    row.add(messageType);
    row.add(_logMessageSource(container.source) ?? 'Unknown');
    row.add(container.lastUpdate);
    row.add(container.macAddress);
    return row;
  }

  static List<List<dynamic>> _logMessagesInContainer(
      MessageContainer container) {
    final csvData = <List<dynamic>>[];
    if (container.locationMessage != null) {
      final row = logMetadata(container, 'Location');
      row.addAll(_logLocationMessage(container.locationMessage!));
      csvData.add(row);
    }
    if (container.basicIdMessages != null) {
      for (final basicIdMessage in container.basicIdMessages!.values) {
        final row = logMetadata(container, 'Basic ID');
        row.addAll(_logBasicMessage(basicIdMessage));
        csvData.add(row);
      }
    }
    if (container.operatorIdMessage != null) {
      final row = logMetadata(container, 'Operator ID');
      row.addAll(_logOperatorMessage(container.operatorIdMessage!));
      csvData.add(row);
    }
    if (container.selfIdMessage != null) {
      final row = logMetadata(container, 'Self ID');
      row.addAll(_logSelfIdMessage(container.selfIdMessage!));
      csvData.add(row);
    }
    if (container.authenticationMessage != null) {
      final row = logMetadata(container, 'Authentication');
      row.addAll(_logAuthMessage(container.authenticationMessage!));
      csvData.add(row);
    }
    if (container.systemDataMessage != null) {
      final row = logMetadata(container, 'System Data');
      row.addAll(_logSystemDataMessage(container.systemDataMessage!));
      csvData.add(row);
    }
    return csvData;
  }
}
