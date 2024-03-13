import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/export_cubit.dart';
import '../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../bloc/zones/selected_zone_cubit.dart';
import '../../../constants/sizes.dart';
import '../../app/dialogs.dart';

enum AircraftAction {
  delete,
  shareCsv,
  shareGpx,
  mapLock,
}

Future<AircraftAction?> displayAircraftActionMenu(BuildContext context) async {
  const labelStyle = TextStyle(
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    items: [
      PopupMenuItem(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.mapLock,
        enabled:
            messagePackList.isNotEmpty && messagePackList.last.locationValid,
        child: Text(
          context.read<MapCubit>().state.lockOnPoint
              ? 'Unfollow'
              : 'Follow aircraft',
          style: labelStyle,
        ),
      ),
      const PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.shareCsv,
        child: Text(
          'Export to CSV',
          style: labelStyle,
        ),
      ),
      const PopupMenuItem(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        value: AircraftAction.shareGpx,
        child: Text(
          'Export to GPX',
          style: labelStyle,
        ),
      ),
      const PopupMenuItem(
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
      context.read<SlidersCubit>().isPanelOpened()
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
          final alertsCubit = context.read<ProximityAlertsCubit>();
          if (messagePackList.last.basicIdMessages != null) {
            for (final basicIdMessage
                in messagePackList.last.basicIdMessages!.values) {
              alertsCubit.clearFoundDrone(basicIdMessage.uasID.asString());
            }
          }
          context.read<SlidersCubit>().setShowDroneDetail(show: false);
          context.read<AircraftCubit>().deletePack(selectedMac);
          context.read<SelectedAircraftCubit>().unselectAircraft();
          context.read<MapCubit>().turnOffLockOnPoint();

          showSnackBar(
            context,
            'Aircraft data were deleted.',
          );
        },
      );
      break;
    case AircraftAction.shareCsv:
      context
          .read<ExportCubit>()
          .exportPack(
              format: ExportFormat.csv, mac: messagePackList.last.macAddress)
          .then(
        (value) {
          if (value) {
            showSnackBar(context, 'CSV shared successfuly.');
          } else {
            showSnackBar(
              context,
              'Sharing data was not succesful.',
            );
          }
        },
      );
      break;
    case AircraftAction.shareGpx:
      context
          .read<ExportCubit>()
          .exportPack(
              format: ExportFormat.gpx, mac: messagePackList.last.macAddress)
          .then(
        (value) {
          if (value) {
            showSnackBar(context, 'GPX shared successfuly.');
          } else {
            showSnackBar(
              context,
              'Sharing data was not succesful.',
            );
          }
        },
      );
      break;
    case AircraftAction.mapLock:
      late final String snackBarText;
      // if setting lock or centering to zone, hide slider to snap point
      if (!context.read<MapCubit>().state.lockOnPoint) {
        context.read<SlidersCubit>().animatePanelToSnapPoint();
        snackBarText = 'Map center locked on aircraft.';
      } else {
        snackBarText = 'Map center lock on aircraft was disabled.';
      }
      // aircraft
      if (messagePackList.isNotEmpty && messagePackList.last.locationValid) {
        context.read<MapCubit>().toggleLockOnPoint();
        context.read<MapCubit>().centerToLocDouble(
              messagePackList.last.locationMessage!.location!.latitude,
              messagePackList.last.locationMessage!.location!.longitude,
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
