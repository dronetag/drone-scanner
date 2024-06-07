import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/utils/utils.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../bloc/units_settings_cubit.dart';
import '../../../bloc/zones/selected_zone_cubit.dart';
import '../../../bloc/zones/zone_item.dart';
import '../../../models/unit_value.dart';

class ZoneDetail extends StatelessWidget {
  const ZoneDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final zoneItem = context.watch<SelectedZoneCubit>().state.selectedZone!;
    final countryCode = zoneItem.country;
    UnitValue? distanceFromMe;

    if (context.read<StandardsCubit>().state.locationEnabled &&
        context.read<MapCubit>().state.userLocationValid) {
      distanceFromMe =
          context.read<UnitsSettingsCubit>().distanceDefaultToCurrent(
                calculateDistance(
                  zoneItem.coordinates.first.latitude,
                  zoneItem.coordinates.first.longitude,
                  context.read<MapCubit>().state.userLocation.latitude,
                  context.read<MapCubit>().state.userLocation.longitude,
                ),
              );
    }
    var zoneType = '';
    final zoneTypeRaw = zoneItem.type.toString().replaceAll('ZoneType.', '');
    for (var i = 0; i < zoneTypeRaw.length; ++i) {
      if (i == 0) {
        zoneType += zoneTypeRaw[i].toUpperCase();
      } else {
        // add space infront of new word
        if (zoneTypeRaw[i] == zoneTypeRaw[i].toUpperCase()) zoneType += ' ';
        zoneType += zoneTypeRaw[i];
      }
    }
    const icon = Icons.dangerous;
    Image? flag;
    if (countryCode != null) {
      try {
        flag = Image.network(
          'https://flagcdn.com/h20/${countryCode.toLowerCase()}.png',
          width: 24,
          height: 12,
          alignment: Alignment.centerLeft,
        );
      } on Exception {
        flag = null;
      }
    }
    return ListTile(
      leading: const Icon(icon),
      title: Text.rich(
        TextSpan(text: zoneItem.name),
      ),
      subtitle: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Zone ID:'),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (countryCode != null && flag != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: flag,
                      ),
                    TextSpan(text: zoneItem.id),
                  ],
                ),
              ),
            ),
            const Text('AM ID:'),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text.rich(
                TextSpan(
                  text: '${zoneItem.amId}',
                ),
              ),
            ),
            Row(
              children: [
                const Text('Upper Altitude:'),
                const Spacer(),
                Text('${zoneItem.upperAltitude} ${zoneItem.upperAltitudeRef}'),
              ],
            ),
            Row(
              children: [
                const Text('Lower Altitude:'),
                const Spacer(),
                Text('${zoneItem.lowerAltitude} ${zoneItem.lowerAltitudeRef} '),
              ],
            ),
            Row(
              children: [
                const Text('Zone type:'),
                const Spacer(),
                Text(zoneType),
              ],
            ),
            if (context.read<StandardsCubit>().state.locationEnabled &&
                distanceFromMe != null)
              Row(
                children: [
                  const Text('Distance from me:'),
                  const Spacer(),
                  Text(distanceFromMe.toStringAsFixed(6)),
                ],
              ),
            const Text('Points:'),
            _buildTable(context, zoneItem),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, ZoneItem zoneItem) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        const TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: Text(
                  'Latitude',
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: Text(
                  'Longitude',
                ),
              ),
            ),
          ],
        ),
        ...zoneItem.coordinates.map(
          (e) => TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: Text(
                    e.latitude.toStringAsFixed(6),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Center(
                  child: Text(
                    e.longitude.toStringAsFixed(5),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
