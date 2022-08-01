import 'dart:async';

import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

const defaultAccuracy = loc.LocationAccuracy.high;
const defaultInterval = 10000;

class Location {
  final double latitude;
  final double longitude;

  const Location({required this.latitude, required this.longitude});
}

class LocationService {
  final loc.Location location = loc.Location();

  Location? lastLocation;

  bool enabled = false;
  bool settingsSet = false;
  loc.PermissionStatus permissions = loc.PermissionStatus.denied;

  bool get missingGrantedPermission =>
      permissions != loc.PermissionStatus.granted;

  void _setSettings() {
    location.changeSettings(interval: defaultInterval);
    settingsSet = true;
  }

  Future<bool> enableService() async {
    enabled = await location.serviceEnabled();
    if (!enabled) {
      enabled = await location.requestService();
      if (!enabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> requestPermissions() async {
    permissions = await location.requestPermission();
    if (missingGrantedPermission) {
      return false;
    }
    return true;
  }

  Future<bool> ensurePermissionsGranted() async {
    if (await Permission.location.isGranted == false) {
      await Permission.location.request();
    }

    return Permission.location.isGranted;
  }

  Future<Location?> getCurrentLocation({
    bool shouldRequestPermission = true,
  }) async {
    // Check if service running
    if (enabled == false) {
      if (!await enableService()) return null;
    }

    // Check if permissions are granted
    if (missingGrantedPermission) {
      permissions = await location.hasPermission();
      if (missingGrantedPermission) {
        if (!shouldRequestPermission || !await requestPermissions()) {
          return null;
        }
      }
    }

    if (!settingsSet) _setSettings();

    final locationData = await location.getLocation();

    if (locationData.latitude == null || locationData.longitude == null) {
      return null;
    }

    return lastLocation = Location(
      latitude: locationData.latitude!,
      longitude: locationData.longitude!,
    );
  }
}
