part of 'map_cubit.dart';

enum MapStyle {
  normal,
  satellite,
}

class GMapState {
  bool isReady;
  bool userLocationValid = false;
  bool wasCenteredOnUser = false;
  bool lockOnPoint = false;
  bool droppedPin = false;
  gmap.LatLng userLocation = const gmap.LatLng(0, 0);
  gmap.LatLng pinLocation = const gmap.LatLng(0, 0);
  gmap.MapType mapStyle = gmap.MapType.normal;

  GMapState({
    required this.isReady,
    required this.userLocationValid,
    required this.wasCenteredOnUser,
    required this.lockOnPoint,
    required this.droppedPin,
    required this.userLocation,
    required this.pinLocation,
    required this.mapStyle,
  });

  static GMapState get defaults => GMapState(
        isReady: false,
        userLocationValid: false,
        wasCenteredOnUser: false,
        lockOnPoint: false,
        droppedPin: false,
        userLocation: const gmap.LatLng(0, 0),
        pinLocation: const gmap.LatLng(0, 0),
        mapStyle: gmap.MapType.normal,
      );

  GMapState copyWith({
    bool? isReady,
    bool? userLocationValid,
    bool? wasCenteredOnUser,
    bool? lockOnPoint,
    bool? droppedPin,
    gmap.LatLng? centerLocation,
    gmap.LatLng? userLocation,
    gmap.LatLng? pinLocation,
    gmap.MapType? mapStyle,
  }) =>
      GMapState(
        isReady: isReady ?? this.isReady,
        userLocationValid: userLocationValid ?? this.userLocationValid,
        wasCenteredOnUser: wasCenteredOnUser ?? this.wasCenteredOnUser,
        lockOnPoint: lockOnPoint ?? this.lockOnPoint,
        droppedPin: droppedPin ?? this.droppedPin,
        userLocation: userLocation ?? this.userLocation,
        pinLocation: pinLocation ?? this.pinLocation,
        mapStyle: mapStyle ?? this.mapStyle,
      );
}
