import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class ProximityAlert extends StatelessWidget {
  final String text;

  const ProximityAlert({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.red),
      ),
      margin: EdgeInsets.symmetric(horizontal: Sizes.mapContentMargin),
      padding: EdgeInsets.all(
        Sizes.mapContentMargin / 2,
      ),
      width: MediaQuery.of(context).size.width - 2 * Sizes.mapContentMargin,
      child: Column(
        children: [
          Text(text),
          ElevatedButton(
              onPressed: () {
                context
                    .read<ProximityAlertsCubit>()
                    .setAlertDismissed(dismissed: true);
              },
              child: Text('Dismiss')),
        ],
      ),
    );
  }
}
