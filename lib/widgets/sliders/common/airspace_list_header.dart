import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/screen_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../utils/utils.dart';
import '../../preferences/components/custom_dropdown_button.dart';
import '../../showcase/showcase_item.dart';
import 'chevron.dart';
import 'num_drones_text.dart';

class AirspaceListHeader extends StatelessWidget {
  final Chevron chevron;
  final Function(SortValue) setSortCallback;
  final Function(FilterValue) setFilterCallback;
  const AirspaceListHeader({
    Key? key,
    required this.chevron,
    required this.setFilterCallback,
    required this.setSortCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final headerHeight = calcHeaderHeight(context);
    chevron.context = context;
    chevron.color = AppColors.lightGray;
    final screenCubit = context.read<ScreenCubit>();

    const labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.lightGray,
      fontSize: 16.0,
    );
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
      ),
      height: headerHeight,
      width: width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenCubit.scaleHeight * 5.0),
            child: CustomPaint(
              painter: chevron,
              child: Container(
                margin:
                    EdgeInsets.symmetric(vertical: screenCubit.scaleHeight * 5),
                width: width / 8,
                height: headerHeight / 15,
              ),
            ),
          ),
          if (context.read<SlidersCubit>().panelController.state != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.mapContentMargin,
                vertical: screenCubit.scaleHeight * 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const NumDronesText(),
                  // filtering is not used, uncomment when zones are implemented
                  /*
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          const SizedBox(),
                          if (context.watch<SlidersCubit>().state.filterValue !=
                              FilterValue.zones)
                            const Text(
                              'Show',
                              textScaleFactor: 0.9,
                              style: labelStyle,
                            ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (context.read<SlidersCubit>().state.filterValue !=
                              FilterValue.zones)
                            buildFilterCombo(context),
                        ],
                      ),
                    ),*/
                  if (!context.read<SlidersCubit>().isPanelClosed())
                    Row(
                      children: [
                        const SizedBox(),
                        if (context.watch<SlidersCubit>().state.filterValue !=
                            FilterValue.zones)
                          const Text(
                            'Sort by',
                            style: labelStyle,
                          ),
                        const SizedBox(
                          width: 5,
                        ),
                        if (context.read<SlidersCubit>().state.filterValue !=
                            FilterValue.zones)
                          buildSortCombo(context),
                      ],
                    ),

                  /*const SizedBox(
                      width: 10,
                    ),
                    if (context.read<SlidersCubit>().state.filterValue ==
                        FilterValue.zones)
                      SizedBox(
                        width: width / 3,
                      ),*/
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
