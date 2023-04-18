import 'package:flutter/material.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class ProximityAlertWidget extends StatelessWidget {
  final ProximityAlert alert;

  const ProximityAlertWidget({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.red),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(
        Sizes.mapContentMargin / 2,
      ),
      width: MediaQuery.of(context).size.width - 2 * Sizes.mapContentMargin,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: Sizes.iconPadding),
                  child:
                      Icon(Icons.location_searching, size: Sizes.textIconSize)),
              Text(
                alert.uasId,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              Text(
                '~${alert.distance.toStringAsFixed(1)} m away',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
