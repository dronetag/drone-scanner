import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../utils/utils.dart';

class AircraftCardTitle extends StatelessWidget {
  final String uasId;
  final String? givenLabel;
  const AircraftCardTitle({
    Key? key,
    required this.uasId,
    required this.givenLabel,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final proximityAlertsActive =
        context.read<ProximityAlertsCubit>().state.isAlertActiveForId(uasId);

    final manufacturer =
        context.read<AircraftCubit>().getModelInfo(uasId)?.maker;

    final logo = getManufacturerLogo(
        manufacturer: manufacturer,
        color: proximityAlertsActive ? AppColors.green : Colors.black);

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
          color: proximityAlertsActive ? AppColors.green : null,
        ),
        children: [
          if (givenLabel == null && manufacturer != null && logo != null) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: logo,
            ),
            const TextSpan(text: ' '),
          ],
          if (proximityAlertsActive)
            const WidgetSpan(
              child: Icon(
                Icons.person,
                color: AppColors.green,
                size: Sizes.textIconSize,
              ),
            ),
          if (givenLabel != null) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.label_outline,
                size: Sizes.textIconSize,
                color: proximityAlertsActive ? AppColors.green : Colors.black,
              ),
            ),
            const TextSpan(text: ' '),
          ],
          TextSpan(
            text: givenLabel == null ? '$uasId' : '$givenLabel',
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }
}
