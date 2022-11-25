import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/zones/selected_zone_cubit.dart';
import '../../../constants/sizes.dart';
import '../../app/dialogs.dart';

enum AircraftAction {
  delete,
  share,
  export,
  mapLock,
}

Future<AircraftAction?> displayAircraftActionMenu(BuildContext context) async {
  final labelStyle = TextStyle(
    fontSize: 16,
  );
  final selectedMac =
      context.read<SelectedAircraftCubit>().state.selectedAircraftMac;
  if (selectedMac == null) return null;
  final messagePackList = context.read<AircraftCubit>().packsForDevice(
        selectedMac,
      );
  if (messagePackList == null || messagePackList.isEmpty) {
    return null;
  }
  return showMenu<AircraftAction>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    items: [
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.mapLock,
        enabled:
            messagePackList.isNotEmpty && messagePackList.last.locationValid(),
        child: Text(
          context.read<MapCubit>().state.lockOnPoint
              ? 'Unfollow'
              : 'Follow aircraft',
          style: labelStyle,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.share,
        child: Text(
          'Export Data',
          style: labelStyle,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.delete,
        child: Text(
          'Delete',
          style: labelStyle,
        ),
      ),
    ],
    position: RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width,
      context.read<SlidersCubit>().panelController.isPanelOpen
          ? MediaQuery.of(context).size.height / 6
          : MediaQuery.of(context).size.height / 4 * 3,
      Sizes.screenSpacing,
      Sizes.screenSpacing,
    ),
  );
}

void handleAction(BuildContext context, AircraftAction action) {
  final zoneItem = context.read<SelectedZoneCubit>().state.selectedZone;
  final selectedMac =
      context.read<SelectedAircraftCubit>().state.selectedAircraftMac;
  if (selectedMac == null) return;
  final messagePackList = context.read<AircraftCubit>().packsForDevice(
        selectedMac,
      );
  if (messagePackList == null || messagePackList.isEmpty) {
    return;
  }

  switch (action) {
    case AircraftAction.delete:
      showAlertDialog(
        context,
        'Are you sure you want to delete aircraft data?',
        () {
          context.read<SlidersCubit>().setShowDroneDetail(show: false);
          context.read<AircraftCubit>().deletePack(selectedMac);
          context.read<SelectedAircraftCubit>().unselectAircraft();
          showSnackBar(
            context,
            'Aircraft data were deleted.',
          );
        },
      );
      break;
    case AircraftAction.share:
      context
          .read<AircraftCubit>()
          .exportPackToCSV(mac: messagePackList.last.macAddress, save: false)
          .then(
        (value) {
          if (value.isNotEmpty) {
            showSnackBar(context, 'CSV shared successfuly.');
          }
        },
      );
      break;
    case AircraftAction.export:
      context
          .read<AircraftCubit>()
          .exportPackToCSV(mac: messagePackList.last.macAddress, save: true)
          .then(
        (value) {
          showSnackBar(context, 'Saved successfuly to $value');
        },
      );
      break;
    case AircraftAction.mapLock:
      late final String snackBarText;
      // if setting lock or centering to zone, hide slider to snap point
      if (!context.read<MapCubit>().state.lockOnPoint) {
        context.read<SlidersCubit>().panelController.animatePanelToSnapPoint();
        snackBarText = 'Map center locked on aircraft.';
      } else {
        snackBarText = 'Map center lock on aircraft was disabled.';
      }
      // aircraft
      if (messagePackList.isNotEmpty && messagePackList.last.locationValid()) {
        context.read<MapCubit>().toggleLockOnPoint();
        context.read<MapCubit>().centerToLocDouble(
              messagePackList.last.locationMessage!.latitude!,
              messagePackList.last.locationMessage!.longitude!,
            );
      } else {
        if (zoneItem != null) {
          context.read<MapCubit>().centerToLocDouble(
                zoneItem.coordinates.first.latitude,
                zoneItem.coordinates.first.longitude,
              );
        }
      }
      showSnackBar(context, snackBarText);
      break;
    default:
  }
}
