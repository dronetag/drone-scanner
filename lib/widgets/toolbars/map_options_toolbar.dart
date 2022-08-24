import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../app/dialogs.dart';
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
        : MediaQuery.of(context).size.height / 6;
    const toolbarWidth = 35.0;
    return BlocBuilder<StandardsCubit, StandardsState>(
      builder: (context, state) {
        return ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().mapToolbarKey,
          description: context.read<ShowcaseCubit>().mapToolbarDescription,
          title: 'Map Options',
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.droneScannerLightGray.withOpacity(0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(Sizes.panelBorderRadius),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(blurRadius: 10.0, color: Color.fromRGBO(0, 0, 0, 0.1))
              ],
            ),
            height: toolbarHeight,
            width: toolbarWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: toolbarWidth,
                  height: toolbarHeight / 3,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: Sizes.iconSize,
                    onPressed: () {
                      context.read<MapCubit>().centerToUser();
                    },
                    icon: const Icon(
                      Icons.location_searching,
                    ),
                  ),
                ),
                SizedBox(
                  width: toolbarWidth,
                  height: toolbarHeight / 3,
                  child: IconButton(
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
                ),
                SizedBox(
                  width: toolbarWidth,
                  height: toolbarHeight / 3,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showAlertDialog(
                        context,
                        'Are you sure you want to delete all gathered data?',
                        () {
                          context
                              .read<SlidersCubit>()
                              .setShowDroneDetail(show: false);
                          context.read<AircraftCubit>().clear();
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
