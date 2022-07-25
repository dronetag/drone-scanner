import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../constants/colors.dart';
import '../../preferences/components/custom_dropdown_button.dart';
import '../../showcase/showcase_item.dart';
import 'chevron.dart';
import 'num_drones_text.dart';

class AirspaceListHeader extends StatelessWidget {
  final Chevron chevron;
  final Function setSortCallback;
  final Function setFilterCallback;
  const AirspaceListHeader({
    Key? key,
    required this.chevron,
    required this.setFilterCallback,
    required this.setSortCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerHeight = isLandscape ? height / 6 : height / 12;
    chevron.setContext(context);
    chevron.setColor(AppColors.droneScannerLightGray);
    if (chevron.getDirection() != ChevronDirection.none) {
      chevron.setDirection(context.watch<SlidersCubit>().state.sliderMaximized
          ? ChevronDirection.downwards
          : ChevronDirection.upwards);
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: headerHeight,
      width: width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: CustomPaint(
              painter: chevron,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: headerHeight / 5 * 3,
                height: headerHeight / 10,
              ),
            ),
          ),
          if (context.read<SlidersCubit>().panelController.isAttached &&
              !context.read<SlidersCubit>().panelController.isPanelClosed)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // hide zones, fix later
                  /*
                  const Text("Show:"),
                  buildFilterCombo(context),
                  */
                  const NumDronesText(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(),
                        if (context.watch<SlidersCubit>().state.filterValue !=
                            FilterValue.zones)
                          const Text('Sort by'),
                        const SizedBox(
                          width: 5,
                        ),
                        if (context.read<SlidersCubit>().state.filterValue !=
                            FilterValue.zones)
                          buildSortCombo(context),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (context.read<SlidersCubit>().state.filterValue ==
                      FilterValue.zones)
                    SizedBox(
                      width: width / 3,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSortCombo(BuildContext context) {
    final sortItems = <String>[
      'UAS ID',
      'Time',
      if (context.read<MapCubit>().state.userLocationValid) 'Distance',
    ];
    return ShowcaseItem(
      showcaseKey: context.read<ShowcaseCubit>().droneListSortKey,
      description: context.read<ShowcaseCubit>().droneListSortDescription,
      title: 'List Panel',
      child: CustomDropdownButton(
        value: context.read<SlidersCubit>().state.sortValueString(),
        valueChangedCallback: (newValue) {
          setSortCallback(SortValue.values[sortItems.indexOf(newValue!)]);
        },
        items: sortItems,
      ),
    );
  }

  Widget buildFilterCombo(BuildContext context) {
    final filterItems = <String>[
      'All',
      'Aircraft',
      'Zones',
    ];
    return ShowcaseItem(
      showcaseKey: context.read<ShowcaseCubit>().droneListFilterKey,
      description: context.read<ShowcaseCubit>().droneListFilterDescription,
      title: 'List Panel',
      child: CustomDropdownButton(
        value: context.read<SlidersCubit>().state.filterValueString(),
        valueChangedCallback: (newValue) {
          setFilterCallback(FilterValue.values[filterItems.indexOf(newValue!)]);
        },
        items: filterItems,
      ),
    );
  }
}
