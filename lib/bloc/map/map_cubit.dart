import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import '../../constants/theme_map.dart';
import '../../services/location_service.dart';
import '../../utils/google_map_style_reader.dart';
import '../aircraft/aircraft_cubit.dart';
import '../aircraft/selected_aircraft_cubit.dart';
import '../sliders_cubit.dart';
import '../zones/selected_zone_cubit.dart';
import '../zones/zone_item.dart';
import '../zones/zones_cubit.dart';

part 'map_state.dart';

class MapCubit extends Cubit<GMapState> {
  final GoogleMapStyleReader _stylesReader = GoogleMapStyleReader();
  final LocationService _locationService;
  gmap.GoogleMapController? controller;
  gmap.CameraPosition position = const gmap.CameraPosition(
    target: gmap.LatLng(50.5, 14.25),
    zoom: 11.0,
  );
  List<VoidCallback> postLoadCallbacks = [];

  MapCubit(LocationService locationService)
      : _locationService = locationService,
        super(GMapState.defaults);

  Future<void> assignController(gmap.GoogleMapController controller) async {
    // wait for map ready hack
    // https://github.com/flutter/flutter/issues/27936#issuecomment-541313108
    await controller.getVisibleRegion();
    this.controller = controller;

    for (final callback in postLoadCallbacks) {
      callback();
    }
    postLoadCallbacks = [];
    if (state.userLocationValid) await centerToUser();
    emit(state.copyWith(isReady: true));
  }

  Future<void>? centerTo(gmap.CameraPosition position) =>
      moveCamera(gmap.CameraUpdate.newCameraPosition(position));

  Future<void>? moveCamera(gmap.CameraUpdate update) {
    return controller?.animateCamera(update);
  }

  Future<void>? changeZoom(double zoomDelta) {
    return controller?.getZoomLevel().then(
      (currentZoomLevel) {
        currentZoomLevel = currentZoomLevel + zoomDelta;
        controller?.animateCamera(
          gmap.CameraUpdate.newCameraPosition(
            gmap.CameraPosition(
              target: position.target,
              zoom: currentZoomLevel,
            ),
          ),
        );
      },
    );
  }

  Future<void>? centerToUser() {
    if (state.userLocation.longitude == INV_LAT &&
        state.userLocation.latitude == INV_LON) {
      return Future.error('bad loc');
    }
    return controller?.getZoomLevel().then((currentZoomLevel) {
      moveCamera(
        gmap.CameraUpdate.newCameraPosition(
          gmap.CameraPosition(
            target: state.userLocation,
            zoom: currentZoomLevel < 14.0 ? 14.0 : currentZoomLevel,
          ),
        ),
      );
      if (!state.wasCenteredOnUser) {
        emit(state.copyWith(wasCenteredOnUser: true));
      }
    });
  }

  Future<void>? centerToLoc(gmap.LatLng loc) {
    return controller?.getZoomLevel().then(
      (currentZoomLevel) {
        moveCamera(
          gmap.CameraUpdate.newCameraPosition(
            gmap.CameraPosition(target: loc, zoom: currentZoomLevel),
          ),
        );
      },
    );
  }

  Future<void>? centerToLocDouble(double lat, double long) =>
      centerToLoc(gmap.LatLng(lat, long));

  Future<void> setDroppedPin({required bool pinDropped}) async {
    emit(state.copyWith(droppedPin: pinDropped));
  }

  Future<void> toggleLockOnPoint() async {
    emit(state.copyWith(lockOnPoint: !state.lockOnPoint));
  }

  Future<void> setUserLocation(gmap.LatLng loc) async {
    emit(state.copyWith(userLocation: loc, userLocationValid: true));
  }

  Future<void> setUserLocationDouble(double lat, double long) async {
    emit(
      state.copyWith(
        userLocation: gmap.LatLng(lat, long),
        userLocationValid: true,
      ),
    );
  }

  Future<void> setDroppedPinLocation(gmap.LatLng loc) async {
    emit(state.copyWith(pinLocation: loc));
  }

  Future<void> setLockOnPoint({required bool lock}) async {
    emit(state.copyWith(lockOnPoint: lock));
  }

  Future<void> setMapStyle([gmap.MapType? s]) async {
    s ??= state.mapStyle;
    await controller?.setMapStyle(_stylesReader.getStyleJson(s));
    emit(state.copyWith(mapStyle: s));
  }

  gmap.CameraPosition getInitialCameraPosition() {
    final phoneLocation = _locationService.lastLocation;

    if (phoneLocation == null) {
      return const gmap.CameraPosition(
        target: gmap.LatLng(
          50.073658,
          14.418540,
        ),
        zoom: 12,
      );
    }

    return gmap.CameraPosition(
      target: gmap.LatLng(phoneLocation.latitude, phoneLocation.longitude),
      zoom: 12.0,
    );
  }

  void setCameraMoving({required bool moving}) {
    emit(state.copyWith(cameraMoving: moving));
  }

  List<dynamic> constructAirspaceMapObjects(BuildContext context) {
    final selZone = context.watch<SelectedZoneCubit>().state.selectedZone;
    final selItemMac =
        context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
    return [
      ...buildPolygonZones(context, selZone),
      ...buildMarkers(context, selItemMac),
      ...buildCircleZones(context, selZone),
      ...buildPolylines(context, selItemMac),
    ];
  }

  Set<gmap.Polygon> buildPolygonZones(BuildContext context, ZoneItem? selZone) {
    return context.watch<SlidersCubit>().state.filterValue !=
            FilterValue.aircraft
        ? context
            .watch<ZonesCubit>()
            .state
            .zones
            .where((element) => element.regionType == 'Polygon')
            .map(
              (e) => gmap.Polygon(
                points: e.coordinates,
                polygonId: gmap.PolygonId(e.name),
                fillColor: selZone == e
                    ? MapAppTheme.selectedZoneColor
                    : MapAppTheme.airspaceZoneColor[e.type] ??
                        MapAppTheme.defaultZoneColor,
                strokeColor: selZone == e
                    ? MapAppTheme.selectedZoneStrokeColor
                    : MapAppTheme.airspaceZoneStrokeColor[e.type] ??
                        MapAppTheme.defaultZoneStrokeColor,
                strokeWidth: 1,
                consumeTapEvents: true,
                onTap: () {
                  context.read<SelectedZoneCubit>().selectZone(e);
                  context.read<SelectedAircraftCubit>().unselectAircraft();
                  context.read<MapCubit>().centerToLocDouble(
                        e.coordinates.first.latitude,
                        e.coordinates.first.longitude,
                      );
                  context.read<SlidersCubit>().setShowDroneDetail(show: true);
                },
              ),
            )
            .toSet()
        : {};
  }

  Set<gmap.Circle> buildCircleZones(BuildContext context, ZoneItem? selZone) {
    return context.watch<SlidersCubit>().state.filterValue !=
            FilterValue.aircraft
        ? context
            .watch<ZonesCubit>()
            .state
            .zones
            .where((element) => element.regionType == 'Circle')
            .map(
              (e) => gmap.Circle(
                center: e.coordinates.first,
                circleId: gmap.CircleId(e.name),
                radius: e.radius ?? 0,
                fillColor: selZone == e
                    ? MapAppTheme.selectedZoneColor
                    : MapAppTheme.airspaceZoneColor[e.type] ??
                        MapAppTheme.defaultZoneColor,
                strokeColor: selZone == e
                    ? MapAppTheme.selectedZoneStrokeColor
                    : MapAppTheme.airspaceZoneStrokeColor[e.type] ??
                        MapAppTheme.defaultZoneStrokeColor,
                strokeWidth: 1,
                consumeTapEvents: true,
                onTap: () {
                  context.read<SelectedZoneCubit>().selectZone(e);
                  context.read<SelectedAircraftCubit>().unselectAircraft();
                  context.read<MapCubit>().centerToLocDouble(
                        e.coordinates.first.latitude,
                        e.coordinates.first.longitude,
                      );
                  context.read<SlidersCubit>().setShowDroneDetail(show: true);
                },
              ),
            )
            .toSet()
        : {};
  }

  Set<gmap.Marker> buildMarkers(BuildContext context, String? selItemMac) {
    // ignore: omit_local_variable_types
    final Set<gmap.Marker> markers = context
                .watch<SlidersCubit>()
                .state
                .filterValue !=
            FilterValue.zones
        ? context.read<AircraftCubit>().state.packHistory().values.isEmpty
            ? {}
            : context
                .read<AircraftCubit>()
                .state
                .packHistory()
                .values
                .where(
                  (e) => e.isNotEmpty && e.last.locationValid(),
                )
                .map(
                (e) {
                  late final double markerHue;
                  if (selItemMac != null && e.last.macAddress == selItemMac) {
                    markerHue = gmap.BitmapDescriptor.hueRed;
                  } else if (e.last.locationMessage == null ||
                      e.last.locationMessage?.status == AircraftStatus.Ground) {
                    markerHue = 195;
                  } else {
                    markerHue = gmap.BitmapDescriptor.hueBlue;
                  }
                  var haslocation = (e.isNotEmpty && e.last.locationValid());
                  final uasIdText = e.last.basicIdMessage != null
                      ? e.last.basicIdMessage?.uasId
                      : 'Unknown UAS ID';
                  final givenLabel = context
                      .read<AircraftCubit>()
                      .getAircraftLabel(e.last.macAddress);

                  final infoWindowText = givenLabel ?? uasIdText;
                  return gmap.Marker(
                    markerId: gmap.MarkerId(e.last.macAddress),
                    infoWindow: gmap.InfoWindow(
                      title: infoWindowText,
                    ),
                    position: haslocation
                        ? gmap.LatLng(
                            e.last.locationMessage!.latitude!,
                            e.last.locationMessage!.longitude!,
                          )
                        : const gmap.LatLng(0, 0),
                    onTap: () {
                      context
                          .read<SelectedAircraftCubit>()
                          .selectAircraft(e.last.macAddress);
                      context.read<SelectedZoneCubit>().unselectZone();
                      if (haslocation) {
                        context.read<MapCubit>().centerToLocDouble(
                              e.last.locationMessage!.latitude!,
                              e.last.locationMessage!.longitude!,
                            );
                      }
                      context
                          .read<SlidersCubit>()
                          .setShowDroneDetail(show: true);
                      if (context
                          .read<SlidersCubit>()
                          .panelController
                          .isPanelClosed) {
                        context
                            .read<SlidersCubit>()
                            .panelController
                            .animatePanelToSnapPoint();
                      }
                    },
                    icon: gmap.BitmapDescriptor.defaultMarkerWithHue(markerHue),
                  );
                },
              ).toSet()
        : {};
    // if sel drone has pilot location, show it with a marker
    if (selItemMac != null &&
        context.read<AircraftCubit>().packsForDevice(selItemMac) != null &&
        context
            .read<AircraftCubit>()
            .packsForDevice(selItemMac)!
            .last
            .systemDataValid()) {
      final systemData = context
          .read<AircraftCubit>()
          .packsForDevice(selItemMac)!
          .last
          .systemDataMessage;
      if (systemData != null) {
        markers.add(
          gmap.Marker(
            markerId: const gmap.MarkerId('takeoff'),
            infoWindow: const gmap.InfoWindow(
              title: 'Operator Location',
            ),
            icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
              gmap.BitmapDescriptor.hueYellow,
            ),
            position: gmap.LatLng(
              systemData.operatorLatitude,
              systemData.operatorLongitude,
            ),
          ),
        );
      }
    }
    // add dropped pin if it exists
    if (context.watch<MapCubit>().state.droppedPin) {
      markers.add(
        gmap.Marker(
          markerId: const gmap.MarkerId('pin'),
          infoWindow: const gmap.InfoWindow(
            title: 'Pin',
          ),
          icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
            gmap.BitmapDescriptor.hueMagenta,
          ),
          position: gmap.LatLng(
            context.read<MapCubit>().state.pinLocation.latitude,
            context.read<MapCubit>().state.pinLocation.longitude,
          ),
        ),
      );
    }
    return markers;
  }

  Set<gmap.Polyline> buildPolylines(BuildContext context, String? selItemMac) {
    // ignore: omit_local_variable_types
    final Set<gmap.Polyline> polylines = {};
    List<MessagePack>? selItemHistory;
    if (selItemMac == null) return {};
    selItemHistory =
        context.read<AircraftCubit>().state.packHistory()[selItemMac];
    if (selItemHistory == null) return {};
    const maxPoints = 75;
    var filteredList = <MessagePack>[];
    // calc portion of history that will be filtered out
    final skip = selItemHistory.length ~/ maxPoints;

    if (skip <= 1) {
      filteredList = selItemHistory;
    } else {
      for (var i = 0; i < selItemHistory.length; ++i) {
        if ((i % skip) == 0) {
          filteredList.add(selItemHistory[i]);
        }
      }
    }
    final polylineData = filteredList.where((e) => e.locationValid()).map(
      (e) {
        return gmap.LatLng(
          e.locationMessage!.latitude!,
          e.locationMessage!.longitude!,
        );
      },
    ).toList();
    polylines.add(
      gmap.Polyline(
        polylineId: gmap.PolylineId(selItemMac),
        points: polylineData,
        color: MapAppTheme.flightTrajectoryStrokeColor,
        width: MapAppTheme.flightTrajectoryStrokeWidth,
      ),
    );
    return polylines;
  }
}
