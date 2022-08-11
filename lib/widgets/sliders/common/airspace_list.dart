import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../../utils/utils.dart';
import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/standards_cubit.dart';
import '../../../bloc/zones/selected_zone_cubit.dart';
import '../../../bloc/zones/zones_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../showcase/showcase_item.dart';
import '../aircraft/aircraft_card.dart';
import '../zones/zone_card.dart';

class AirspaceList extends StatelessWidget {
  const AirspaceList({
    Key? key,
    required this.filterValue,
    required this.sortValue,
  }) : super(key: key);

  final FilterValue filterValue;
  final SortValue sortValue;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final maxSliderHeight = maxSliderSize(
      height: height,
      statusBarHeight: MediaQuery.of(context).viewPadding.top,
      androidSystem: context.read<StandardsCubit>().state.androidSystem,
    );
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerHeight = isLandscape ? height / 6 : height / 12;
    final minSliderHeight = isLandscape
        ? height / Sizes.toolbarMinSizeRatioLandscape
        : height / Sizes.toolbarMinSizeRatioPortrait;
    final snapHeight =
        minSliderHeight + (maxSliderHeight - minSliderHeight) * 0.3;
    final contentHeight = context.watch<SlidersCubit>().isAtSnapPoint()
        ? snapHeight - headerHeight
        : maxSliderHeight - headerHeight;

    final children = buildListChildren(context);
    return ShowcaseItem(
      showcaseKey: context.read<ShowcaseCubit>().droneListKey,
      description: context.read<ShowcaseCubit>().droneListDescription,
      title: 'List Panel',
      child: Column(
        children: [
          Expanded(
            child: NotificationListener<OverscrollNotification>(
              onNotification: (value) {
                // close on overscroll
                context.read<SlidersCubit>().closeSlider();
                return true;
              },
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: headerHeight),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.mapContentMargin),
                    height: contentHeight,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: children.length,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return children[index];
                      },
                      separatorBuilder: (context, _) {
                        return Divider(
                          color: AppColors.lightGray,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildListChildren(BuildContext context) {
    final state = context.watch<AircraftCubit>().state;
    late final Map<String, List<MessagePack>> aircraft;
    if (sortValue == SortValue.uasid) {
      aircraft = state.packHistoryByUASID();
    } else if (sortValue == SortValue.time) {
      aircraft = state.packHistoryByLastUpdate();
    } else {
      aircraft = state
          .packHistoryByDistance(context.watch<MapCubit>().state.userLocation);
    }
    if (context.read<ShowcaseCubit>().state.showcaseActive) {
      return [
        ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().droneListItemKey,
          description: context.read<ShowcaseCubit>().droneListItemDescription,
          title: 'List Panel',
          opacity: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          child: AircraftCard(
            messagePack: aircraft.values.first.last,
          ),
        )
      ];
    } else {
      return [
        if (filterValue == FilterValue.aircraft ||
            filterValue == FilterValue.all)
          ...aircraft.values
              .where((element) => element.isNotEmpty)
              .map(
                (value) => GestureDetector(
                  child: AircraftCard(
                    messagePack: value.last,
                  ),
                  onTap: () {
                    context
                        .read<SelectedAircraftCubit>()
                        .selectAircraft(value.last.macAddress);
                    context.read<SelectedZoneCubit>().unselectZone();
                    if (value.last.locationMessage != null &&
                        value.last.locationMessage?.latitude != null &&
                        value.last.locationMessage?.longitude != null) {
                      context.read<MapCubit>().centerToLocDouble(
                            value.last.locationMessage!.latitude!,
                            value.last.locationMessage!.longitude!,
                          );
                    }
                    context.read<SlidersCubit>().setShowDroneDetail(show: true);
                  },
                ),
              )
              .toList(),
        if (filterValue == FilterValue.zones || filterValue == FilterValue.all)
          ...context
              .watch<ZonesCubit>()
              .state
              .zones
              .map(
                (z) => Column(
                  children: [
                    GestureDetector(
                      child: ZoneCard(
                        zone: z,
                      ),
                      onTap: () {
                        context.read<SelectedZoneCubit>().selectZone(z);
                        context
                            .read<SelectedAircraftCubit>()
                            .unselectAircraft();
                        context.read<MapCubit>().centerToLocDouble(
                              z.coordinates.first.latitude,
                              z.coordinates.first.longitude,
                            );
                        context
                            .read<SlidersCubit>()
                            .setShowDroneDetail(show: true);
                      },
                    ),
                    Divider(color: Theme.of(context).colorScheme.secondary),
                  ],
                ),
              )
              .toList(),
      ];
    }
  }
}
