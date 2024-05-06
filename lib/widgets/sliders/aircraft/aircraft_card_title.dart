import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_metadata_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../common/manufacturer_logo.dart';

class AircraftCardTitle extends StatelessWidget {
  final String uasId;
  final String? givenLabel;

  const AircraftCardTitle({
    super.key,
    required this.uasId,
    required this.givenLabel,
  });

  @override
  Widget build(BuildContext context) {
    final proximityAlertsActive =
        context.read<ProximityAlertsCubit>().state.isAlertActiveForId(uasId);

    final manufacturer =
        context.read<AircraftMetadataCubit>().getModelInfo(uasId)?.maker;

    final logo = _getLogo(
        context: context,
        proximityAlertsActive: proximityAlertsActive,
        manufacturer: manufacturer);

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
          ],
          TextSpan(
            text: givenLabel ?? uasId,
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget? _getLogo(
      {required BuildContext context,
      required bool proximityAlertsActive,
      required String? manufacturer}) {
    return manufacturer != null
        ? ManufacturerLogo(
            manufacturer: manufacturer,
            color: proximityAlertsActive ? AppColors.green : Colors.black)
        : null;
  }
}
