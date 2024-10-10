import 'package:permission_handler/permission_handler.dart';

final _usedPermissionsDisplayNames = {
  Permission.bluetooth: 'Bluetooth',
  Permission.bluetoothScan: 'Bluetooth nearby scan',
  Permission.bluetoothConnect: 'Bluetooth connect',
  Permission.location: 'Location',
  Permission.locationAlways: 'Location',
  Permission.locationWhenInUse: 'Location',
};

const String btScanStartMessage = 'Bluetooth Scanning Started.';
const String btScanStopMessage = 'Bluetooth Scanning Stopped.';
const String wifiScanStartMessage = 'Wi-Fi Scanning Started.';
const String wifiScanStopMessage = 'Wi-Fi Scanning Stopped.';

String btTurnedOffMessage({required bool isAndroidSystem}) {
  // on the ios, if bt perm is not granted
  // bt behaves like it is turned off
  if (isAndroidSystem) {
    return 'Turn Bluetooth on to start scanning.';
  } else {
    return 'Turn Bluetooth on to start scanning. '
        'Make sure that the application has '
        'Bluetooth permission granted.';
  }
}

const String wifiTurnedOffMessage = 'Turn Wi-Fi on to start scanning.';

String unableToStartMessage(String description) {
  return 'Unable to start scan: '
      '$description.';
}

String getPermissionDisplayName(Permission permission) =>
    _usedPermissionsDisplayNames[permission] ??
    permission.toString().split('.').last;

String getMissingPermissionsMessage(List<Permission> missingPermissions) {
  if (missingPermissions.length == 1) {
    return '${getPermissionDisplayName(missingPermissions.first)} '
        'permission was not granted';
  }
  return 'Following permissions were not granted: '
      '${missingPermissions.map(getPermissionDisplayName).join(', ')}';
}
