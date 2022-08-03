// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/showcase_cubit.dart';
import 'showcase_start_widget.dart';

class ShowcaseRoot extends StatelessWidget {
  const ShowcaseRoot({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Showcase.withWidget(
        shapeBorder: const CircleBorder(),
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
        child: const SizedBox(
          width: 1,
          height: 1,
        ),
      ),
    );
  }
}
