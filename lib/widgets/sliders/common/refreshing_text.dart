import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../../bloc/aircraft/aircraft_expiration_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../constants/colors.dart';

class RefreshingText extends StatefulWidget {
  final String? leadingText;
  final MessagePack pack;
  final double scaleFactor;
  final bool short;
  final FontWeight fontWeight;
  final bool showExpiryWarning;
  final Color textColor;

  const RefreshingText({
    Key? key,
    required this.pack,
    this.leadingText,
    this.scaleFactor = 0.9,
    this.short = false,
    this.showExpiryWarning = false,
    this.fontWeight = FontWeight.normal,
    this.textColor = AppColors.detailFieldColor,
  }) : super(key: key);

  @override
  State<RefreshingText> createState() => _RefreshingTextState();
}

class _RefreshingTextState extends State<RefreshingText> {
  void handleTimeout(Timer timer) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tstamp = widget.pack.lastUpdate.millisecondsSinceEpoch;
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        final packAge = (DateTime.now().millisecondsSinceEpoch - tstamp) / 1000;
        final expiresSoon =
            !context.watch<ShowcaseCubit>().state.showcaseActive &&
                context.watch<AircraftExpirationCubit>().state.cleanOldPacks &&
                ((context.watch<AircraftExpirationCubit>().state.cleanTimeSec -
                        packAge) <
                    3);
        final sec = (DateTime.now().millisecondsSinceEpoch - tstamp) / 1000;
        final min = (sec / 60).floor();
        final minText = min < 1 ? '' : '${min}m';
        final secText =
            sec < 1 ? '< 1 s' : '${(sec - min * 60).toStringAsFixed(0)}s';
        var text = '';
        if (!widget.short) {
          text = widget.leadingText != null
              ? '${widget.leadingText!}: $minText $secText ago'
              : '$minText $secText ago';
        } else {
          text = min >= 1 ? minText : secText;
          text += ' ago';
        }
        if (widget.showExpiryWarning && expiresSoon && !widget.short) {
          final expiryTime =
              context.watch<AircraftExpirationCubit>().state.cleanTimeSec -
                  packAge;
          text += '\nExpires in ${expiryTime.toStringAsFixed(0)} sec';
        }
        return Text(
          text,
          textScaleFactor: widget.scaleFactor,
          style: TextStyle(
            color: expiresSoon && widget.showExpiryWarning
                ? AppColors.red
                : widget.textColor,
            fontWeight: widget.fontWeight,
          ),
        );
      },
    );
  }
}
