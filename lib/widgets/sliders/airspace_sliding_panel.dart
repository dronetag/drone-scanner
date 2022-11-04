import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../bloc/aircraft/aircraft_bloc.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/zones/selected_zone_cubit.dart';
import 'aircraft/detail/aircraft_detail.dart';
import 'aircraft/detail/aircraft_detail_header.dart';
import 'common/airspace_list.dart';
import 'common/airspace_list_header.dart';
import 'common/chevron.dart';
import 'zones/zone_detail.dart';

class AirspaceSlidingPanel extends StatefulWidget {
  final double maxSize;
  final double minSize;

  const AirspaceSlidingPanel({
    required this.maxSize,
    required this.minSize,
    Key? key,
  }) : super(key: key);

  @override
  State<AirspaceSlidingPanel> createState() => _AircraftSlidingPanelState();
}

class _AircraftSlidingPanelState extends State<AirspaceSlidingPanel>
    with WidgetsBindingObserver {
  Chevron chevron = Chevron();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<SlidersCubit>().panelController.animatePanelToSnapPoint());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sliderMaximized = context.watch<SlidersCubit>().state.sliderMaximized;
    final borderRadius =
        sliderMaximized ? Radius.zero : const Radius.circular(10);
    return BlocBuilder<SlidersCubit, SlidersState>(
      builder: (context, state) {
        // check if aircraft to be shown was not deleted
        if (state.showDroneDetail) {
          final selMac =
              context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
          final messagePackList = selMac != null
              ? context.watch<AircraftBloc>().packsForDevice(selMac)
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
            return SlidingUpPanel(
              controller: context.read<SlidersCubit>().panelController,
              maxHeight: widget.maxSize,
              minHeight: widget.minSize,
              snapPoint: orientation == Orientation.landscape ? null : 0.3,
              onPanelSlide: (_) {
                if (context.read<SlidersCubit>().state.sliderMaximized) {
                  context
                      .read<SlidersCubit>()
                      .setSliderMaximized(maximized: false);
                }
                if (chevron.direction != ChevronDirection.none) {
                  setState(() {
                    chevron.direction = ChevronDirection.none;
                  });
                }
              },
              borderRadius: BorderRadius.only(
                topLeft: borderRadius,
                topRight: borderRadius,
              ),
              boxShadow: const [],
              onPanelOpened: () {
                chevron.direction = ChevronDirection.downwards;
                context
                    .read<SlidersCubit>()
                    .setSliderMaximized(maximized: true);
              },
              onPanelClosed: () {
                chevron.direction = ChevronDirection.upwards;
                context
                    .read<SlidersCubit>()
                    .setSliderMaximized(maximized: false);
              },
              header: buildHeader(width, state),
              panel: state.showDroneDetail
                  ? buildDetailPanel(context)
                  : buildListPanel(context),
            );
          },
        );
      },
    );
  }

  void onHeaderTapPortrait() {
    final controller = context.read<SlidersCubit>().panelController;
    if (controller.isPanelClosed || controller.isPanelOpen) {
      controller.animatePanelToSnapPoint();
    }
  }

  void onHeaderTapLandscape() {
    final controller = context.read<SlidersCubit>().panelController;
    if (controller.isPanelClosed) {
      controller.open();
    } else {
      controller.close();
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
