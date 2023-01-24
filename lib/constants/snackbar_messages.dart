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
