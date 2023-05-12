import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/zones/selected_zone_cubit.dart';
import '../../utils/utils.dart';
import 'aircraft/detail/aircraft_detail.dart';
import 'aircraft/detail/aircraft_detail_header.dart';
import 'common/airspace_list.dart';
import 'common/airspace_list_header.dart';
import 'common/chevron.dart';
import 'zones/zone_detail.dart';

class AirspaceSlidingPanel extends StatefulWidget {
  const AirspaceSlidingPanel({
    Key? key,
  }) : super(key: key);

  @override
  State<AirspaceSlidingPanel> createState() => _AircraftSlidingPanelState();
}

class _AircraftSlidingPanelState extends State<AirspaceSlidingPanel>
    with WidgetsBindingObserver {
  Chevron chevron = Chevron();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sliderMaximized = context.watch<SlidersCubit>().isPanelOpened();
    final borderRadius = sliderMaximized ? 0.0 : 10.0;
    return BlocBuilder<SlidersCubit, SlidersState>(
      builder: (context, state) {
        // check if aircraft to be shown was not deleted
        if (state.showDroneDetail) {
          final selMac =
              context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
          final messagePackList = selMac != null
              ? context.watch<AircraftCubit>().packsForDevice(selMac)
              : null;
          // empty or was deleted, return to list
          if (messagePackList == null || messagePackList.isEmpty) {
            context.read<SlidersCubit>().setShowDroneDetail(show: false);
            return Container();
          }
        }
        // use orientation builder to rebuild widget when orientation changes
        return OrientationBuilder(
          builder: (context, orientation) {
            return SlidingSheet(
              controller: context.read<SlidersCubit>().panelController,
              snapSpec: SnapSpec(
                snap: true,
                snappings: SlidersCubit.snappings,
                initialSnap: SlidersCubit.middleSnap,
                positioning: SnapPositioning.relativeToAvailableSpace,
                onSnap: (p0, snap) {
                  late final ChevronDirection dir;
                  if (snap == SlidersCubit.bottomSnap) {
                    dir = ChevronDirection.upwards;
                  } else if (snap == SlidersCubit.topSnap) {
                    dir = ChevronDirection.downwards;
                  } else {
                    dir = ChevronDirection.none;
                  }
                  if (chevron.direction != dir) {
                    setState(() {
                      chevron.direction = dir;
                    });
                  }
                },
              ),
              cornerRadius: borderRadius,
              headerBuilder: (context, sheetState) => buildHeader(width, state),
              builder: (context, sheetState) {
                final cubit = context.read<SlidersCubit>();
                final height = MediaQuery.of(context).size.height;
                final maxSliderHeight = height * SlidersCubit.topSnap;
                final headerHeight = calcHeaderHeight(context);
                final snapHeight = height * SlidersCubit.middleSnap;
                final contentHeight =
                    sheetState.extent == SlidersCubit.middleSnap
                        ? (snapHeight - headerHeight) + 1
                        : maxSliderHeight - headerHeight;

                return Container(
                  height: contentHeight,
                  child: state.showDroneDetail
                      ? buildDetailPanel(context)
                      : buildListPanel(context),
                );
              },
            );
          },
        );
      },
    );
  }

  void onHeaderTapPortrait() {
    final cubit = context.read<SlidersCubit>();
    if (cubit.isPanelClosed() || cubit.isPanelOpened()) {
      cubit.animatePanelToSnapPoint();
    }
  }

  void onHeaderTapLandscape() {
    final cubit = context.read<SlidersCubit>();
    if (cubit.isPanelClosed()) {
      cubit.openSlider();
    } else {
      cubit.closeSlider();
    }
  }

  Widget buildListPanel(BuildContext context) {
    return AirspaceList(
      filterValue: context.read<SlidersCubit>().state.filterValue,
      sortValue: context.read<SlidersCubit>().state.sortValue,
    );
  }

  Widget buildDetailPanel(BuildContext context) {
    // if none of both aircraft and zone are selected, stop
    if ((!context.read<SelectedAircraftCubit>().isAircraftSelected &&
            !context.read<SelectedZoneCubit>().isZoneSelected) ||
        (context.read<SelectedAircraftCubit>().isAircraftSelected &&
            context.read<SelectedZoneCubit>().isZoneSelected)) {
      return Container();
    }

    return context.read<SelectedAircraftCubit>().isAircraftSelected
        ? const AircraftDetail()
        : const ZoneDetail();
  }

  Widget buildHeader(double width, SlidersState state) {
    if (state.showDroneDetail) {
      return GestureDetector(
        onTap: MediaQuery.of(context).orientation == Orientation.landscape
            ? onHeaderTapLandscape
            : onHeaderTapPortrait,
        child: AircraftDetailHeader(chevron: chevron),
      );
    } else {
      // ignore: prefer_function_declarations_over_variables
      final setFilterCallback = (filter) {
        setState(() {
          if (filter is FilterValue) {
            context.read<SlidersCubit>().setFilterValue(filter);
          }
        });
      };

      // ignore: prefer_function_declarations_over_variables
      final setSortCallback = (sort) {
        setState(() {
          if (sort is SortValue) {
            context.read<SlidersCubit>().setSortValue(sort);
          }
        });
      };

      return GestureDetector(
        onTap: MediaQuery.of(context).orientation == Orientation.landscape
            ? onHeaderTapLandscape
            : onHeaderTapPortrait,
        child: AirspaceListHeader(
          chevron: chevron,
          setFilterCallback: setFilterCallback,
          setSortCallback: setSortCallback,
        ),
      );
    }
  }
}
