import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/proximity_alerts_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../preferences/components/proximity_alert_widget.dart';

class ProximityAlertSnackbar extends StatefulWidget {
  final List<ProximityAlert> list;
  final int expirationTime;
  const ProximityAlertSnackbar({
    Key? key,
    required this.list,
    required this.expirationTime,
  }) : super(key: key);

  @override
  _ProximityAlertSnackbarState createState() => _ProximityAlertSnackbarState();
}

class _ProximityAlertSnackbarState extends State<ProximityAlertSnackbar>
    with TickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.expirationTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerText = widget.list.length > 1
        ? '${widget.list.length} drones are flying close'
        : '1 drone is flying close';
    final width =
        MediaQuery.of(context).size.width - 2 * Sizes.mapContentMargin;
    controller.animateTo(1);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.red,
        ),
        color: AppColors.lightRed,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.lightRed,
            ),
            width: width,
            padding: EdgeInsets.only(
              left: Sizes.standard,
              right: Sizes.standard,
              bottom: Sizes.standard,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: Sizes.iconPadding),
                      child: Icon(
                        Icons.error_outline,
                        size: Sizes.textIconSize,
                        color: AppColors.red,
                      ),
                    ),
                    Text(
                      headerText,
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      onPressed: () {
                        context
                            .read<ProximityAlertsCubit>()
                            .setAlertDismissed(dismissed: true);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.red,
                        //size: Sizes.textIconSize,
                      ),
                      iconSize: Sizes.textIconSize,
                    )
                  ],
                ),
                ...widget.list
                    .map(
                      (e) => Container(
                        color: AppColors.lightRed,
                        child: ProximityAlertWidget(
                          alert: e,
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          Container(
            //alignment: Alignment.bottomCenter,
            height: 10.0,
            width: width,
            //padding: EdgeInsets.only(top: Sizes.standard * 2),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => CustomPaint(
                painter: CustomTimerPainter(
                    animation: controller,
                    backgroundColor: AppColors.lightRed,
                    color: AppColors.red,
                    height: 10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
    required this.height,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = height
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    paint.color = color;
    var progress = animation.value;
    canvas.drawLine(Offset.zero, Offset(size.width * (1 - progress), 0), paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
