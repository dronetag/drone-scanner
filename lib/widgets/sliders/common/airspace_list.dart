import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.mapContentMargin),
                child: ListView.separated(
                  padding: MediaQuery.of(context).padding.copyWith(top: 0.0),
                  itemCount: children.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: children[index],
                    );
                  },
                  separatorBuilder: (context, _) {
                    return Divider(
                      color: AppColors.lightGray,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildListChildren(BuildContext context) {
    final state = context.watch<AircraftCubit>().state;
    Map<String, List<MessageContainer>> aircraft;
    final userAircraftUasId =
        context.watch<ProximityAlertsCubit>().state.usersAircraftUASID;
    final userDronePositioning =
        context.watch<SlidersCubit>().state.myDronePositioning;
    if (sortValue == SortValue.uasid) {
      aircraft =
          state.packHistoryByUASID(userAircraftUasId, userDronePositioning);
    } else if (sortValue == SortValue.time) {
      aircraft = state.packHistoryByLastUpdate(
          userAircraftUasId, userDronePositioning);
    } else {
      aircraft = state.packHistoryByDistance(
          context.watch<MapCubit>().state.userLocation,
          userAircraftUasId,
          userDronePositioning);
    }

    if (context.read<ShowcaseCubit>().state.showcaseActive &&
        aircraft.isNotEmpty) {
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
                    context.read<MapCubit>().turnOffLockOnPoint();
                    context.read<SelectedZoneCubit>().unselectZone();
                    if (value.last.locationValid()) {
                      context.read<MapCubit>().centerToLocDouble(
                            value.last.locationMessage!.location!.latitude,
                            value.last.locationMessage!.location!.longitude,
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
                        context.read<MapCubit>().turnOffLockOnPoint();
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
