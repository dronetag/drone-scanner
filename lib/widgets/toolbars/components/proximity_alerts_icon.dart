import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/sizes.dart';

class ProximityAlertsIcon extends StatefulWidget {
  const ProximityAlertsIcon({Key? key}) : super(key: key);

  @override
  State<ProximityAlertsIcon> createState() => _ProximityAlertsIconState();
}

class _ProximityAlertsIconState extends State<ProximityAlertsIcon> {
  void handleTimeout(Timer timer) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        if (context.watch<ProximityAlertsCubit>().state.proximityAlertActive &&
            context.watch<ProximityAlertsCubit>().state.hasRecentAlerts()) {
          return IconButton(
            icon: Icon(Icons.warning),
            color: Colors.white,
            iconSize: Sizes.iconSize,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () =>
                context.read<ProximityAlertsCubit>().showExpiredAlerts(),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
