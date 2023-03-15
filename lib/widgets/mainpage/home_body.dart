import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/wakelock.dart';

import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/screen_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/utils.dart';
import '../showcase/showcase_item.dart';
import '../sliders/airspace_sliding_panel.dart';
import '../toolbars/map_options_toolbar.dart';
import '../toolbars/toolbar.dart';
import 'map_ui_google.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    Key? key,
  }) : super(key: key);

  Stack buildMapView(BuildContext context) {
    final proximityAlert = context.watch<ProximityAlertsCubit>().state.alert;
    final height = MediaQuery.of(context).size.height;
    // acc to doc, wakelock should not be used in main but in widgets build m
    Wakelock.toggle(
        enable: context.watch<ScreenCubit>().state.screenSleepDisabled);
    return Stack(
      children: <Widget>[
        ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().mapKey,
          description: context.read<ShowcaseCubit>().mapDescription,
          title: 'Map',
          padding: EdgeInsets.only(bottom: -height / 3),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: const MapUIGoogle(),
          ),
        ),
        if (proximityAlert != null)
          Positioned(
            top: height / 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.red),
              ),
              margin: EdgeInsets.symmetric(horizontal: Sizes.mapContentMargin),
              padding: EdgeInsets.all(Sizes.mapContentMargin),
              width: MediaQuery.of(context).size.width -
                  2 * Sizes.mapContentMargin,
              child: Text(proximityAlert),
            ),
          ),
        const Toolbar(),
        Positioned(
          top: Sizes.toolbarHeight +
              MediaQuery.of(context).viewPadding.top +
              Sizes.mapContentMargin +
              context.read<ScreenCubit>().scaleHeight * 25,
          right: Sizes.mapContentMargin,
          child: MapOptionsToolbar(),
        ),
        AirspaceSlidingPanel(
          maxSize: maxSliderSize(
            height: height,
            statusBarHeight: MediaQuery.of(context).viewPadding.top,
            androidSystem: context.read<StandardsCubit>().state.androidSystem,
          ),
          minSize: calcHeaderHeight(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // rebuild home page when showcase active changes
    context.read<ScreenCubit>().initScreen();
    context.watch<ShowcaseCubit>().state.showcaseActive;
    context.read<ShowcaseCubit>().displayShowcase().then((status) {
      if (status) {
        context.read<ShowcaseCubit>().startShowcase(context);
      }
    });
    return buildMapView(context);
  }
}
