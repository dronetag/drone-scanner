import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../preferences/components/proximity_alert_widget.dart';

class ProximityAlertSnackbar extends StatefulWidget {
  final int expirationTime;
  const ProximityAlertSnackbar({
    Key? key,
    required this.expirationTime,
  }) : super(key: key);

  @override
  _ProximityAlertSnackbarState createState() => _ProximityAlertSnackbarState();
}

class _ProximityAlertSnackbarState extends State<ProximityAlertSnackbar>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  ProximityAlertsCubit? alertsCubit;
  bool active = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.expirationTime),
    );
  }

  @override
  void dispose() {
    active = false;
    alertsCubit?.onAlertsExpired();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width - 2 * Sizes.mapContentMargin;

    final progressBarHeight = 8.0;
    alertsCubit = context.read<ProximityAlertsCubit>();
    controller.animateTo(1);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.panelBorderRadius),
        color: AppColors.lightRed,
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 3),
            color: AppColors.shadow,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Sizes.panelBorderRadius),
                topRight: Radius.circular(Sizes.panelBorderRadius),
              ),
              color: AppColors.lightRed,
            ),
            width: width,
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.standard * 2,
              vertical: Sizes.standard,
            ),
            child: StreamBuilder(
              stream: alertsCubit!.alertStream,
              builder: (context, snapshot) {
                if (!snapshot.hasError &&
                    snapshot.data is List<ProximityAlert> &&
                    (snapshot.data as List<ProximityAlert>).isNotEmpty) {
                  final data = snapshot.data as List<ProximityAlert>;
                  final dronesText =
                      data.length > 1 ? '${data.length} drones' : '1 drone';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: Sizes.standard * 1.5,
                          top: Sizes.standard / 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: Sizes.iconPadding,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: Sizes.textIconSize,
                                color: AppColors.red,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: dronesText,
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${data.length > 1 ? 'are' : 'is'} flying close',
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                if (!active) return;
                                Navigator.pop(context);
                                active = false;
                              },
                              child: Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: controller,
                                    builder: (context, child) => Text(
                                      '${(widget.expirationTime * (1 - controller.value)).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppColors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.close_rounded,
                                    color: AppColors.red,
                                    size: Sizes.textIconSize * 1.2,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      ...(snapshot.data as List<ProximityAlert>)
                          .whereType<DroneNearbyAlert>()
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: Sizes.standard),
                              child: GestureDetector(
                                onTap: () {
                                  if (!active) return;
                                  final data = context
                                      .read<AircraftCubit>()
                                      .findByUasID(e.uasId);
                                  if (data == null) return;
                                  if (data.locationValid()) {
                                    context.read<MapCubit>().centerToLocDouble(
                                          data.locationMessage!.latitude!,
                                          data.locationMessage!.longitude!,
                                        );
                                  }
                                  context
                                      .read<SelectedAircraftCubit>()
                                      .selectAircraft(data.macAddress);
                                  context
                                      .read<SlidersCubit>()
                                      .setShowDroneDetail(show: true);
                                  if (context
                                      .read<SlidersCubit>()
                                      .isPanelClosed()) {
                                    context
                                        .read<SlidersCubit>()
                                        .animatePanelToSnapPoint();
                                  }
                                },
                                child: Container(
                                  color: AppColors.lightRed,
                                  child: ProximityAlertWidget(
                                    alert: e,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          Container(
            height: progressBarHeight,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Sizes.panelBorderRadius),
                bottomRight: Radius.circular(Sizes.panelBorderRadius),
              ),
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => CustomPaint(
                painter: CustomTimerPainter(
                  animation: controller,
                  backgroundColor: AppColors.lightRed,
                  color: AppColors.red,
                  height: progressBarHeight,
                  borderRadius: Sizes.panelBorderRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter(
      {required this.animation,
      required this.backgroundColor,
      required this.color,
      required this.height,
      required this.borderRadius})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;
  final double height;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill;

    final usableWidth = size.width - 2 * borderRadius;
    canvas.drawRect(
      Rect.fromLTRB(borderRadius, 0, borderRadius + usableWidth, height),
      paint,
    );
    paint.color = color;
    var progress = animation.value;
    canvas.drawRect(
      Rect.fromLTRB(
        borderRadius - 1,
        0,
        borderRadius + usableWidth * (1 - progress),
        height,
      ),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTRB(0, -height, borderRadius * 2, height),
      math.pi / 2,
      math.pi / 2,
      true,
      paint,
    );
    paint.color = Colors.black;
    canvas.drawRect(
      Rect.fromLTRB(borderRadius + usableWidth * (1 - progress) - 2, 0,
          borderRadius + usableWidth * (1 - progress), height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
