import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/standards_cubit.dart';
import '../../../bloc/zones/zone_item.dart';

class ZoneCard extends StatelessWidget {
  final ZoneItem zone;

  const ZoneCard({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    final countryCode = zone.country;
    final width = MediaQuery.of(context).size.width;

    Image? flag;
    if (countryCode != null &&
        context.watch<StandardsCubit>().state.internetAvailable) {
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
    late final IconData zoneIcon;
    if (zone.type == ZoneType.airport) {
      zoneIcon = Icons.local_airport;
    } else {
      zoneIcon = Icons.dangerous;
    }
    return ListTile(
      leading: SizedBox(width: width / 8, child: Icon(zoneIcon)),
      title: Text.rich(
        TextSpan(text: zone.name),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operator ID row
          Text.rich(
            TextSpan(
              children: [
                if (countryCode != null && flag != null)
                  WidgetSpan(
                    child: flag,
                  ),
                TextSpan(text: zone.id),
              ],
            ),
          ),
          Text('${zone.amId}'),
        ],
      ),
    );
  }
}
