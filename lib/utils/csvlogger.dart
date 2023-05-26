import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import 'utils.dart';

class CSVLogger {
  static const locationFields = 15;
  static const basicFields = 3;
  static const operatorFields = 1;
  static const authFields = 6;
  static const selfIdFields = 2;
  static const systemFields = 12;
  static final commonHeader = <dynamic>[
    // common
    'messageType',
    'messageSource',
    'timestamp',
    'macAddress',
    // location
    'status',
    'direction',
    'speedHori',
    'speedVert',
    'droneLat',
    'droneLon',
    'altitudePressure',
    'altitudeGeodetic',
    'height',
    'heightType',
    'horizontalAccuracy',
    'verticalAccuracy',
    'baroAccuracy',
    'speedAccuracy',
    'timeAccuracy',
    // basic
    'idType', 'uaType', 'uasId',
    // opid
    'operatorId',
    // auth,
    'authType',
    'authDataPage',
    'authLastPageIndex',
    'authLength',
    'authTimestamp',
    'authData',
    // self id
    'descriptionType', 'operationDescription',
    // system
    'operatorLocationType',
    'classificationType',
    'operatorLatitude',
    'operatorLongitude',
    'areaCount',
    'areaRadius',
    'areaCeiling',
    'areaFloor',
    'category',
    'classValue',
    'operatorAltitudeGeo',
  ];

  static void addEmptyFields(List<dynamic> list, int numFields) {
    for (var i = 0; i < numFields; ++i) {
      list.add('');
    }
  }

  static String? logMessageSource(MessageSource? type) =>
      type?.toString().replaceAll('MessageSource.', '');

  static List<dynamic> logLocationMessage(LocationMessage loc) {
    final row = <dynamic>[];
    row.add('Location');
    row.add(logMessageSource(loc.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(loc.receivedTimestamp));
    row.add(loc.macAddress);
    row.add(loc.status?.toString().replaceAll('AircraftStatus.', '') ?? '');
    row.add(directionAsString(loc.direction));
    row.add(getSpeedHorAsString(loc.speedHorizontal));
    row.add(getSpeedHorAsString(loc.speedVertical));
    row.add(loc.latitude ?? '');
    row.add(loc.longitude ?? '');
    row.add(getAltitudeAsString(loc.altitudePressure));
    row.add(getAltitudeAsString(loc.altitudeGeodetic));
    row.add(getAltitudeAsString(loc.height));
    row.add(loc.heightType?.toString().replaceAll('HeightType.', '') ?? '');
    row.add(
      horizontalAccuracyToString(loc.horizontalAccuracy),
    );
    row.add(
      verticalAccuracyToString(loc.verticalAccuracy),
    );
    row.add(verticalAccuracyToString(loc.baroAccuracy));
    row.add(speedAccuracyToString(loc.speedAccuracy));
    row.add(timeAccuracyToString(loc.timeAccuracy));
    addEmptyFields(
      row,
      basicFields + operatorFields + authFields + selfIdFields + systemFields,
    );
    return row;
  }

  static List<dynamic> logBasicMessage(BasicIdMessage message) {
    final row = <dynamic>[];
    row.add('Basic Id');
    row.add(logMessageSource(message.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
    row.add(message.macAddress);
    addEmptyFields(row, locationFields);
    row.add(message.idType
            ?.toString()
            .replaceAll('IdType.', '')
            .replaceAll('_', ' ') ??
        '');
    row.add(message.uaType
            ?.toString()
            .replaceAll('UaType.', '')
            .replaceAll('_', ' ') ??
        '');
    row.add(message.uasId);
    addEmptyFields(
      row,
      operatorFields + authFields + selfIdFields + systemFields,
    );
    return row;
  }

  static List<dynamic> logOperatorMessage(OperatorIdMessage message) {
    final row = <dynamic>[];
    row.add('Operator Id');
    row.add(logMessageSource(message.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
    row.add(message.macAddress);
    addEmptyFields(row, locationFields + basicFields);

    row.add(message.operatorId != OPERATOR_ID_NOT_SET
        ? message.operatorId
        : 'Unknown');
    addEmptyFields(
      row,
      authFields + selfIdFields + systemFields,
    );
    return row;
  }

  static List<dynamic> logAuthMessage(AuthenticationMessage message) {
    final row = <dynamic>[];
    row.add('Authentication');
    row.add(logMessageSource(message.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
    row.add(message.macAddress);
    addEmptyFields(row, locationFields + basicFields + operatorFields);
    row.add(message.authType?.toString().replaceAll('AuthType.', '') ?? '');
    row.add(message.authDataPage);
    row.add(message.authLastPageIndex.toString());
    row.add(message.authLength.toString());
    row.add(
      DateTime.fromMillisecondsSinceEpoch(message.authTimestamp),
    );
    row.add(message.authData);
    addEmptyFields(
      row,
      selfIdFields + systemFields,
    );
    return row;
  }

  static List<dynamic> logSelfIdMessage(SelfIdMessage message) {
    final row = <dynamic>[];
    row.add('Self Id');
    row.add(logMessageSource(message.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
    row.add(message.macAddress);
    addEmptyFields(
        row, locationFields + basicFields + operatorFields + authFields);
    row.add(message.descriptionType);
    row.add(message.operationDescription);
    addEmptyFields(
      row,
      systemFields,
    );
    return row;
  }

  static List<dynamic> logSystemDataMessage(SystemDataMessage message) {
    final row = <dynamic>[];
    row.add('System Id');
    row.add(logMessageSource(message.source) ?? 'Unknown');
    row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
    row.add(message.macAddress);
    addEmptyFields(
        row,
        locationFields +
            basicFields +
            operatorFields +
            authFields +
            selfIdFields);
    row.add(
      message.operatorLocationType
              ?.toString()
              .replaceAll('OperatorLocationType.', '') ??
          '',
    );
    row.add(
      message.classificationType
              ?.toString()
              .replaceAll('ClassificationType.', '') ??
          '',
    );
    row.add(message.operatorLatitude);
    row.add(message.operatorLongitude);
    row.add(message.areaCount);
    row.add(message.areaRadius);
    row.add(getAltitudeAsString(message.areaCeiling));
    row.add(getAltitudeAsString(message.areaFloor));
    row.add(
        message.category?.toString().replaceAll('AircraftCategory.', '') ?? '');
    row.add(
        message.classValue?.toString().replaceAll('AircraftClass.', '') ?? '');
    row.add(getAltitudeAsString(message.operatorAltitudeGeo));

    return row;
  }

  static List<List<dynamic>> createCSV(List<MessagePack> list,
      {bool includeHeader = true}) {
    final csvData = <List<dynamic>>[];
    if (includeHeader) csvData.add(commonHeader);
    for (var i = 0; i < list.length; ++i) {
      final pack = list[i];
      if (pack.locationMessage != null) {
        csvData.add(logLocationMessage(pack.locationMessage!));
      }
      if (pack.basicIdMessage != null) {
        csvData.add(logBasicMessage(pack.basicIdMessage!));
      }
      if (pack.operatorIdMessage != null) {
        csvData.add(logOperatorMessage(pack.operatorIdMessage!));
      }
      if (pack.selfIdMessage != null) {
        csvData.add(logSelfIdMessage(pack.selfIdMessage!));
      }
      if (pack.authenticationMessage != null) {
        csvData.add(logAuthMessage(pack.authenticationMessage!));
      }
      if (pack.systemDataMessage != null) {
        csvData.add(logSystemDataMessage(pack.systemDataMessage!));
      }
    }
    return csvData;
  }
}
