// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/screen_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import 'showcase_start_widget.dart';

class ShowcaseRoot extends StatelessWidget {
  const ShowcaseRoot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 150.0 * context.read<ScreenCubit>().scaleHeight,
      ),
      child: Showcase.withWidget(
        targetShapeBorder: const CircleBorder(),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        container: ShowcaseStartWidget(
          heading: "Welcome to\nDrone Scanner!",
          text: context.read<ShowcaseCubit>().rootDescription,
          startCallback: () {
            final w = ShowCaseWidget.of(context);
            w.next();
          },
          skipCallback: () {
            context
                .read<ShowcaseCubit>()
                .setShowcaseActive(context: context, active: false);
          },
        ),
        key: context.read<ShowcaseCubit>().rootKey,
        child: Container(
          width: 1,
          height: 1,
          color: Colors.black45.withOpacity(0.75),
        ),
      ),
    );
  }
}
