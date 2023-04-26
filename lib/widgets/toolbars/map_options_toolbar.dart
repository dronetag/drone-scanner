import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../app/dialogs.dart';
import '../preferences/components/rotating_icon.dart';
import '../preferences/proximity_alerts_page.dart';
import '../showcase/showcase_item.dart';

class MapOptionsToolbar extends StatelessWidget {
  const MapOptionsToolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final toolbarHeight = isLandscape
        ? MediaQuery.of(context).size.height / 3
        : MediaQuery.of(context).size.height / 5;
    final toolbarWidth = isLandscape
        ? MediaQuery.of(context).size.width / 12
        : MediaQuery.of(context).size.width / 8;
    return BlocBuilder<StandardsCubit, StandardsState>(
      builder: (context, state) {
        return ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().mapToolbarKey,
          description: context.read<ShowcaseCubit>().mapToolbarDescription,
          title: 'Map Options',
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(Sizes.panelBorderRadius),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: Sizes.panelBorderRadius,
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                )
              ],
            ),
            height: toolbarHeight,
            width: toolbarWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  iconSize: Sizes.iconSize,
                  onPressed: () {
                    context
                        .read<MapCubit>()
                        .centerToUser()
                        ?.catchError((error) {
                      showSnackBar(context, 'Location not enabled.');
                    });
                  },
                  icon: const Icon(
                    Icons.location_searching,
                  ),
                ),
                IconButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (context.read<MapCubit>().state.mapStyle ==
                        MapType.normal) {
                      context.read<MapCubit>().setMapStyle(MapType.satellite);
                    } else {
                      context.read<MapCubit>().setMapStyle(MapType.normal);
                    }
                  },
                  iconSize: Sizes.iconSize,
                  icon: const Icon(Icons.layers),
                ),
                IconButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showAlertDialog(
                      context,
                      'Are you sure you want to delete all gathered data?',
                      () {
                        context.read<ProximityAlertsCubit>().clearFoundDrones();
                        context
                            .read<SlidersCubit>()
                            .setShowDroneDetail(show: false);
                        context.read<AircraftCubit>().clear();
                        context
                            .read<SelectedAircraftCubit>()
                            .unselectAircraft();
                        context.read<MapCubit>().turnOffLockOnPoint();
                        showSnackBar(
                          context,
                          'All the gathered aircraft data were deleted.',
                        );
                      },
                    );
                  },
                  iconSize: Sizes.iconSize,
                  icon: const Icon(Icons.delete),
                ),
                ShowcaseItem(
                  showcaseKey: context.read<ShowcaseCubit>().droneRadarKey,
                  description:
                      context.read<ShowcaseCubit>().droneRadarDescription,
                  title: 'Drone Radar',
                  child: IconButton(
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProximityAlertsPage(),
                          settings: RouteSettings(
                            name: ProximityAlertsPage.routeName,
                          ),
                        ),
                      );
                    },
                    iconSize: Sizes.iconSize,
                    icon: RotatingIcon(
                      icon: Image.asset(
                        'assets/images/radar.png',
                        width: Sizes.iconSize,
                      ),
                      rotating: context
                          .read<ProximityAlertsCubit>()
                          .state
                          .proximityAlertActive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
