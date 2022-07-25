import 'package:flutter_opendroneid/models/message_pack.dart';

List<List<dynamic>> createCSV(List<MessagePack> list) {
  var csvData = <List<dynamic>>[];
  for (var i = 0; i < list.length; ++i) {
    final pack = list[i];
    csvData.add(['mac address']);
    csvData.add([pack.macAddress]);
    if (pack.locationMessage != null) {
      final loc = pack.locationMessage!;
      csvData.add(['Location Message', loc.source]);
      var row = <dynamic>[];
      var header = <dynamic>[
        'status',
        'heightType',
        'direction',
        'speedHori',
        'speedVert',
        'droneLat',
        'droneLon',
        'altitudePressure',
        'altitudeGeodetic',
        'height',
        'horizontalAccuracy',
        'verticalAccuracy',
        'baroAccuracy',
        'speedAccuracy',
        'timestamp',
        'timeAccuracy',
      ];
      row.add(loc.status ?? '');
      row.add(loc.heightType ?? '');
      row.add(loc.direction ?? '');
      row.add(loc.speedHorizontal ?? '');
      row.add(loc.speedVertical ?? '');
      row.add(loc.latitude ?? '');
      row.add(loc.latitude ?? '');
      row.add(loc.altitudePressure ?? '');
      row.add(loc.altitudeGeodetic ?? '');
      row.add(loc.height ?? '');
      row.add(loc.horizontalAccuracy ?? '');
      row.add(loc.verticalAccuracy ?? '');
      row.add(loc.baroAccuracy ?? '');
      row.add(loc.speedAccuracy ?? '');
      row.add(loc.time != null
          ? DateTime.fromMillisecondsSinceEpoch(loc.time as int)
          : '');
      row.add(loc.timeAccuracy ?? '');
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.basicIdMessage != null) {
      final message = pack.basicIdMessage!;
      csvData.add(['BasicId Message', message.source]);
      var header = <dynamic>['idType', 'uaType', 'uasId'];
      var row = <dynamic>[];
      row.add(message.idType ?? '');
      row.add(message.uaType ?? '');
      row.add(message.uasId);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.operatorIdMessage != null) {
      final message = pack.operatorIdMessage!;
      csvData.add(['OperatorId Message', message.source]);
      var header = <dynamic>['operatorId'];
      var row = <dynamic>[];
      row.add(message.operatorId);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.selfIdMessage != null) {
      final message = pack.selfIdMessage!;
      csvData.add(['SelfId Message', message.source]);
      var row = <dynamic>[];
      var header = <dynamic>['descriptionType', 'operationDescription'];
      row.add(message.descriptionType);
      row.add(message.operationDescription);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.authenticationMessage != null) {
      final message = pack.authenticationMessage!;
      csvData.add(['Authentication Message', message.source]);
      var header = <dynamic>[
        'authType',
        'authDataPage',
        'authLastPageIndex',
        'authLength',
        'authTimestamp',
        'authData',
      ];
      var row = <dynamic>[];
      row.add(message.authType ?? '');
      row.add(message.authDataPage);
      row.add(message.authLastPageIndex.toString());
      row.add(message.authLength.toString());
      row.add(
        DateTime.fromMillisecondsSinceEpoch(message.authTimestamp),
      );
      row.add(message.authData);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.systemDataMessage != null) {
      final message = pack.systemDataMessage!;
      csvData.add(['System Data Message', message.source]);
      var header = <dynamic>[
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
        'systemTimestamp'
      ];
      var row = <dynamic>[];
      row.add(message.operatorLocationType ?? '');
      row.add(message.classificationType ?? '');
      row.add(message.operatorLatitude);
      row.add(message.operatorLongitude);
      row.add(message.areaCount);
      row.add(message.areaRadius);
      row.add(message.areaCeiling);
      row.add(message.areaFloor);
      row.add(message.category ?? '');
      row.add(message.classValue ?? '');
      row.add(message.operatorAltitudeGeo);
      row.add(DateTime.fromMillisecondsSinceEpoch(message.receivedTimestamp));
      csvData.add(header);
      csvData.add(row);
    }
  }
  return csvData;
}
