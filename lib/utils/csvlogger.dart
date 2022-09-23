import 'package:flutter_opendroneid/models/message_pack.dart';

List<List<dynamic>> createCSV(List<MessagePack> list) {
  final csvData = <List<dynamic>>[];
  for (var i = 0; i < list.length; ++i) {
    final pack = list[i];
    csvData.add(['mac address']);
    csvData.add([pack.macAddress]);
    if (pack.locationMessage != null) {
      final loc = pack.locationMessage!;
      csvData.add(['Location Message', loc.source]);
      final row = <dynamic>[];
      final header = <dynamic>[
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
      row.add(loc.longitude ?? '');
      row.add(loc.altitudePressure ?? '');
      row.add(loc.altitudeGeodetic ?? '');
      row.add(loc.height ?? '');
      row.add(loc.horizontalAccuracy ?? '');
      row.add(loc.verticalAccuracy ?? '');
      row.add(loc.baroAccuracy ?? '');
      row.add(loc.speedAccuracy ?? '');
      row.add(
        loc.time != null
            ? DateTime.fromMillisecondsSinceEpoch(
                loc.time!,
              )
            : '',
      );
      row.add(loc.timeAccuracy ?? '');
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.basicIdMessage != null) {
      final message = pack.basicIdMessage!;
      csvData.add(['BasicId Message', message.source]);
      final header = <dynamic>['idType', 'uaType', 'uasId'];
      final row = <dynamic>[];
      row.add(message.idType ?? '');
      row.add(message.uaType ?? '');
      row.add(message.uasId);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.operatorIdMessage != null) {
      final message = pack.operatorIdMessage!;
      csvData.add(['OperatorId Message', message.source]);
      final header = <dynamic>['operatorId'];
      final row = <dynamic>[];
      row.add(message.operatorId);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.selfIdMessage != null) {
      final message = pack.selfIdMessage!;
      csvData.add(['SelfId Message', message.source]);
      final row = <dynamic>[];
      final header = <dynamic>['descriptionType', 'operationDescription'];
      row.add(message.descriptionType);
      row.add(message.operationDescription);
      csvData.add(header);
      csvData.add(row);
    }
    if (pack.authenticationMessage != null) {
      final message = pack.authenticationMessage!;
      csvData.add(['Authentication Message', message.source]);
      final header = <dynamic>[
        'authType',
        'authDataPage',
        'authLastPageIndex',
        'authLength',
        'authTimestamp',
        'authData',
      ];
      final row = <dynamic>[];
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
      final header = <dynamic>[
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
      final row = <dynamic>[];
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
