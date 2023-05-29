import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class ProximityAlertsIcon extends StatefulWidget {
  const ProximityAlertsIcon({Key? key}) : super(key: key);

  @override
  State<ProximityAlertsIcon> createState() => _ProximityAlertsIconState();
}

class _ProximityAlertsIconState extends State<ProximityAlertsIcon>
    with TickerProviderStateMixin {
  AnimationController? motionController;
  Animation? motionAnimation;

  double iconSize = Sizes.iconSize;
  double upperBound = 1.1;
  double lowerBound = 0.9;

  void handleTimeout(Timer timer) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    motionController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
    motionAnimation = CurvedAnimation(
      parent: motionController!,
      curve: Curves.ease,
    );

    motionController?.forward();
    motionController?.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          motionController?.reverse();
        } else if (status == AnimationStatus.dismissed) {
          motionController?.forward();
        }
      });
    });
    motionController?.addListener(() {
      setState(
        () {
          if (motionController == null) return;
          iconSize = motionController!.value * Sizes.iconSize;
        },
      );
    });
  }

  @override
  void dispose() {
    motionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProximityAlertsCubit>().state;
    return Container(
      width: Sizes.iconSize * upperBound,
      height: Sizes.iconSize * upperBound,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            alignment: Alignment.center,
            icon: Image.asset(
              'assets/images/warning-icon.png',
              color: AppColors.red,
              width: iconSize,
              height: iconSize,
            ),
            color: AppColors.red,
            iconSize: iconSize,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () =>
                context.read<ProximityAlertsCubit>().showExpiredAlerts(),
          ),
          Positioned(
            top: -2,
            right: 0,
            child: Text(
              '${state.foundAircraft.length}',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    // bottomLeft
                    offset: Offset(-0.25, -0.25),
                    color: AppColors.toolbarColor,
                  ),
                  Shadow(
                    // bottomRight
                    offset: Offset(0.25, -0.25),
                    color: AppColors.toolbarColor,
                  ),
                  Shadow(
                    // topRight
                    offset: Offset(0.25, 0.25),
                    color: AppColors.toolbarColor,
                  ),
                  Shadow(
                    // topLeft
                    offset: Offset(-0.25, 0.25),
                    color: AppColors.toolbarColor,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
