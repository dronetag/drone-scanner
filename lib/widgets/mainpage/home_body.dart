import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/map/map_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../constants/sizes.dart';
import '../showcase/showcase_item.dart';
import '../sliders/airspace_sliding_panel.dart';
import '../toolbars/toolbar.dart';
import 'map_ui_google.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    Key? key,
  }) : super(key: key);

  Stack buildMapView(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          child: MapUIGoogle(
            mapObjects:
                context.read<MapCubit>().constructAirspaceMapObjects(context),
          ),
        ),
        ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().mapKey,
          description: context.read<ShowcaseCubit>().mapDescription,
          title: 'Map',
          padding: EdgeInsets.only(bottom: height / 3),
          child: const Toolbar(),
        ),
        AirspaceSlidingPanel(
          maxSize: height - height / 20,
          minSize: isLandscape
              ? height / Sizes.toolbarMinSizeRatioLandscape
              : height / Sizes.toolbarMinSizeRatioPortrait,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // rebuild home page when showcase active changes
    context.watch<ShowcaseCubit>().state.showcaseActive;
    context.read<ShowcaseCubit>().displayShowcase().then((status) {
      if (status) {
        context.read<ShowcaseCubit>().startShowcase(context);
      }
    });
    return buildMapView(context);
  }
}
