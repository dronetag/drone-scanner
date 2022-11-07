// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../bloc/zones/selected_zone_cubit.dart';
import '../showcase/showcase_item.dart';
import '../showcase/showcase_root.dart';

class MapUIGoogle extends StatefulWidget {
  bool get _compassEnabled => true;
  bool get _mapToolbarEnabled => false;
  CameraTargetBounds get _cameraTargetBounds => CameraTargetBounds.unbounded;
  MinMaxZoomPreference get _minMaxZoomPreference =>
      MinMaxZoomPreference.unbounded;
  bool get _rotateGesturesEnabled => false;
  bool get _tiltGesturesEnabled => false;
  bool get _scrollGesturesEnabled => true;
  bool get _zoomControlsEnabled => false;
  bool get _zoomGesturesEnabled => true;
  bool get _indoorViewEnabled => true;
  bool get _myLocationEnabled => true;
  bool get _myTrafficEnabled => false;
  bool get _myLocationButtonEnabled => false;

  const MapUIGoogle({Key? key}) : super(key: key);

  @override
  State<MapUIGoogle> createState() => _MapUIGoogleState();
}

class _MapUIGoogleState extends State<MapUIGoogle> with WidgetsBindingObserver {
  late CameraPosition initialCameraPosition;
  List<dynamic> mapObjects = [];

  @override
  void dispose() {
    context.read<MapCubit>().controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    initialCameraPosition = context.read<MapCubit>().getInitialCameraPosition();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AircraftCubit, AircraftState>(
      buildWhen: (previous, current) {
        return current is AircraftStateUpdate;
      },
      builder: (context, state) => buildMapStack(context),
    );
  }

  Widget buildMapStack(BuildContext context) {
    // do not reload objects if camera is moving
    if (!context.watch<MapCubit>().state.cameraMoving) {
      mapObjects =
          context.read<MapCubit>().constructAirspaceMapObjects(context);
    }
    final height = MediaQuery.of(context).size.height;
    final selZone = context.watch<SelectedZoneCubit>().state.selectedZone;
    final selItemMac =
        context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
    final droppedPin = context.watch<MapCubit>().state.droppedPin;

    final markers = mapObjects.whereType<Marker>().toSet();
    final polygons = mapObjects.whereType<Polygon>().toSet();
    final polylines = mapObjects.whereType<Polyline>().toSet();
    final circles = mapObjects.whereType<Circle>().toSet();

    final googleMap = GoogleMap(
      onTap: selItemMac != null || selZone != null || droppedPin
          ? (_) {
              context.read<SelectedAircraftCubit>().unselectAircraft();
              context.read<SelectedZoneCubit>().unselectZone();
              FocusScope.of(context).unfocus();
              context.read<MapCubit>().setDroppedPin(pinDropped: false);
              context.read<SlidersCubit>().setShowDroneDetail(show: false);
            }
          : null,
      onMapCreated: onMapCreated,
      circles: circles,
      initialCameraPosition: initialCameraPosition,
      compassEnabled: widget._compassEnabled,
      mapToolbarEnabled: widget._mapToolbarEnabled,
      cameraTargetBounds: widget._cameraTargetBounds,
      minMaxZoomPreference: widget._minMaxZoomPreference,
      mapType: context.watch<MapCubit>().state.mapStyle,
      rotateGesturesEnabled: widget._rotateGesturesEnabled,
      scrollGesturesEnabled: widget._scrollGesturesEnabled,
      tiltGesturesEnabled: widget._tiltGesturesEnabled,
      zoomGesturesEnabled: widget._zoomGesturesEnabled,
      zoomControlsEnabled: widget._zoomControlsEnabled,
      indoorViewEnabled: widget._indoorViewEnabled,
      myLocationEnabled: context.watch<StandardsCubit>().state.locationEnabled
          ? widget._myLocationEnabled
          : false,
      myLocationButtonEnabled: widget._myLocationButtonEnabled,
      trafficEnabled: widget._myTrafficEnabled,
      onCameraMove: _updateCameraPosition,
      markers: markers,
      polygons: polygons,
      polylines: polylines,
      onCameraIdle: _cameraMovementEnded,
      onCameraMoveStarted: _cameraMovementStarted,
    );
    return Stack(
      children: [
        GestureDetector(
          //    : null,
          // when locked on point, swipe unlocks movement
          onVerticalDragStart: context.read<MapCubit>().state.lockOnPoint
              ? (details) {
                  if (context.read<MapCubit>().state.lockOnPoint) {
                    context.read<MapCubit>().setLockOnPoint(lock: false);
                  }
                }
              : null,
          onHorizontalDragStart: context.read<MapCubit>().state.lockOnPoint
              ? (details) {
                  if (context.read<MapCubit>().state.lockOnPoint) {
                    context.read<MapCubit>().setLockOnPoint(lock: false);
                  }
                }
              : null,
          child: googleMap,
        ),
        if (context.watch<ShowcaseCubit>().state.showcaseActive)
          const Align(
            alignment: Alignment.topCenter,
            child: ShowcaseRoot(),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 85.0),
            child: ShowcaseItem(
              showcaseKey: context.read<ShowcaseCubit>().lastKey,
              description: context.read<ShowcaseCubit>().lastDescription,
              title: "Tutorial End",
              child: Container(
                width: 1,
                height: 1,
                color: Colors.black45.withOpacity(0.75),
              ),
            ),
          ),
        ),
        if (!context.watch<MapCubit>().state.isReady)
          Align(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: height,
              color: Theme.of(context).colorScheme.background,
              child: const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ignore: use_setters_to_change_properties
  void _updateCameraPosition(CameraPosition position) {
    context.read<MapCubit>().position = position;
  }

  void _cameraMovementStarted() {
    context.read<MapCubit>().setCameraMoving(moving: true);
  }

  void _cameraMovementEnded() {
    context.read<MapCubit>().setCameraMoving(moving: false);
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    await _waitForMapReady(controller);
    if (!mounted) return;
    await context.read<MapCubit>().assignController(controller);
    if (!mounted) return;
    await context.read<MapCubit>().setMapStyle();
  }

  Future<void> _waitForMapReady(GoogleMapController controller) async {
    try {
      await controller.getVisibleRegion();
      // Even the hack with getVisibleRegion doesn't help sometimes
      await Future.delayed(const Duration(milliseconds: 100));
    } on MissingPluginException {
      // Google Maps library sometimes throws this randomly
      // https://github.com/flutter/flutter/issues/43785
      await _waitForMapReady(controller);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // workaround hack for https://github.com/flutter/flutter/issues/40284
      context.read<MapCubit>().setMapStyle();
    }
  }
}
