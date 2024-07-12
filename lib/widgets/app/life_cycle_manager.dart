import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/aircraft/aircraft_expiration_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/opendroneid_cubit.dart';
import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import 'dialogs.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({super.key, required this.child});

  @override
  State<LifeCycleManager> createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  StreamSubscription? showcaseSub;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
      Future.delayed(const Duration(seconds: 5), _checkInternetConnection);
      final alertsState = context.read<ProximityAlertsCubit>().state;
      if (alertsState.proximityAlertActive && alertsState.hasRecentAlerts()) {
        Future.delayed(const Duration(seconds: 1),
            () => context.read<ProximityAlertsCubit>().showExpiredAlerts());
      }
    }
  }

  @override
  void didChangeDependencies() {
    // schedule init after showcase finishes
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        final showcaseState = context.read<ShowcaseCubit>().state;
        // if showcase was not init or is running, listen for finish
        if (showcaseState is ShowcaseStateNotInitialized ||
            showcaseState.showcaseActive) {
          showcaseSub = context.read<ShowcaseCubit>().stream.listen((event) {
            if (event is ShowcaseStateInitialized && !event.showcaseActive) {
              _initPlatformState();
              showcaseSub?.cancel();
            }
          });
          return;
        } else {
          _initPlatformState();
        }
      },
    );

    context.read<StandardsCubit>().fetchAndSetStandards();
    context.read<AircraftExpirationCubit>().fetchSavedSettings();
    context.read<SlidersCubit>().fetchAndSetPreference();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    showcaseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }

  Future<void> _initPermissionsIOS(BuildContext context) async {
    final odidCubit = context.read<OpendroneIdCubit>();
    final standardsCubit = context.read<StandardsCubit>();
    final btStatus = await Permission.bluetooth.request();

    if (btStatus.isGranted) {
      if (!mounted) return;
      standardsCubit.setBluetoothEnabled(enabled: true);
      if (!mounted) return;
      final btTurnedOn = await odidCubit.isBtTurnedOn();

      if (btTurnedOn) {
        await odidCubit.setBtUsed(btUsed: true);
      }
    } else {
      if (!mounted) return;
      standardsCubit.setBluetoothEnabled(enabled: false);
    }

    final status = await Permission.location.request();
    if (status.isGranted) {
      _initLocation();
      if (!mounted) return;
      standardsCubit.setLocationEnabled(enabled: true);
    } else {
      if (!mounted) return;
      standardsCubit.setLocationEnabled(enabled: false);
    }

    final notificationStatus = await Permission.notification.request();
    if (notificationStatus.isGranted) {
      standardsCubit.setNotificationsEnabled(enabled: true);
    }
  }

  Future<void> _initPermissionsAndroid(BuildContext context) async {
    final odidCubit = context.read<OpendroneIdCubit>();
    final standardsCubit = context.read<StandardsCubit>();

    final version = await _getAndroidVersionNumber();
    if (version == null) return;
    final locStatus = await Permission.location.status;
    // show dialog before asking for location
    // when already granted or pernamently denied, request is not needed
    if (!(locStatus.isGranted) && context.mounted) {
      if (await showLocationPermissionDialog(
        context: context,
        showWhileUsingPermissionExplanation: version >= 11,
      )) {
        final status = await Permission.location.request();
        if (status.isDenied) {
          standardsCubit.setLocationEnabled(enabled: false);
        } else {
          _initLocation();
          standardsCubit.setLocationEnabled(enabled: true);
        }
      }
    } else if (locStatus.isGranted) {
      _initLocation();
      standardsCubit.setLocationEnabled(enabled: true);
    }

    final btStatus = await Permission.bluetooth.request();
    // scan makes sense just on android
    final btScanStatus = await Permission.bluetoothScan.request();
    if (btStatus.isGranted && btScanStatus.isGranted) {
      standardsCubit.setBluetoothEnabled(enabled: true);
      final btTurnedOn = await odidCubit.isBtTurnedOn();
      if (btTurnedOn) {
        await odidCubit.setBtUsed(btUsed: true);
      }
    } else {
      standardsCubit.setBluetoothEnabled(enabled: false);
    }
    if (!mounted) {
      return;
    }

    if ((version >= 13 &&
            await Permission.nearbyWifiDevices.request().isGranted) ||
        version < 13) {
      await odidCubit.setWifiUsed(wifiUsed: true);
    }
    // local notifications
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    standardsCubit.setNotificationsEnabled(enabled: result ?? false);
  }

  Future<void> _initBackgroundLocationPermission(BuildContext context) async {
    final standardsCubit = context.read<StandardsCubit>();
    final locStatus = await Permission.location.status;

    final backgroundLocStatus = await Permission.locationAlways.status;
    // do not ask for locationAlways if location is not granted
    if (!locStatus.isGranted) return;
    if ((backgroundLocStatus.isGranted)) {
      standardsCubit.setBackgroundLocationEnabled(enabled: true);
      return;
    }

    if (context.mounted && !standardsCubit.state.backgroundLocationDenied) {
      // show dialog to ask user for background location permission
      if (await showBackgroundPermissionDialog(
        context: context,
      )) {
        final status = await Permission.locationAlways.request();

        if (status.isGranted) {
          if (!mounted) return;
          standardsCubit.setBackgroundLocationEnabled(enabled: true);
        } else {
          if (!mounted) return;
          standardsCubit.setBackgroundLocationEnabled(enabled: false);
        }
      }
      // user denied background loc -> save response and do not ask again
      else {
        await standardsCubit.setBackgroundLocationDenied();
      }
    }
  }

  Future<void> _initPlatformState() async {
    if (Platform.isAndroid) {
      await _initPermissionsAndroid(context);
    } else if (Platform.isIOS) {
      await _initPermissionsIOS(context);
    } else {
      return;
    }

    if (!mounted) return;

    await _initBackgroundLocationPermission(context);

    if (!mounted) return;
    if (context.read<ShowcaseCubit>().state.showcaseActive) {
      await context.read<OpendroneIdCubit>().stop();
    }
    _checkInternetConnection();
  }

  Future<int?> _getAndroidVersionNumber() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidVersion = (await deviceInfo.androidInfo).version.release;
    return int.tryParse(androidVersion);
  }

  void _initLocation() {
    final location = Location();
    location.getLocation().then(_userLocationChanged);
    location.onLocationChanged.listen(_userLocationChanged);
  }

  // check permission status without requests
  Future<void> _checkPermissions() async {
    final standardsCubit = context.read<StandardsCubit>();
    if (!mounted) return;
    final loc = await Permission.location.isGranted;
    // check loc, if was not set before, init listener
    if (loc && !standardsCubit.state.locationEnabled) {
      _initLocation();
    }
    standardsCubit.setLocationEnabled(enabled: loc);
    final backgroundLoc = await Permission.locationAlways.isGranted;
    standardsCubit.setBackgroundLocationEnabled(enabled: backgroundLoc);
    final bt = await Permission.bluetooth.isGranted;
    if (Platform.isAndroid) {
      final btScan = await Permission.bluetoothScan.isGranted;
      standardsCubit.setBluetoothEnabled(enabled: bt && btScan);
    } else {
      standardsCubit.setBluetoothEnabled(enabled: bt);
    }

    standardsCubit.setNotificationsEnabled(
        enabled: await Permission.notification.isGranted);
  }

  void _userLocationChanged(LocationData currentLocation) {
    void updateLoc() {
      final mapCubit = context.read<MapCubit>();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        mapCubit.setUserLocationDouble(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
      // force centering only of first startup
      if (!mapCubit.state.wasCenteredOnUser) {
        mapCubit.centerToUser();
      }
    }

    // do not set state if showcase is running, would restart it
    if (!context.read<ShowcaseCubit>().state.showcaseActive) {
      setState(updateLoc);
    } else {
      updateLoc();
    }
  }

  Future<void> _checkInternetConnection() async {
    // check internet
    final standardsCubit = context.read<StandardsCubit>();
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        standardsCubit.setInternetAvailable(available: true);
      }
    } on SocketException catch (_) {
      standardsCubit.setInternetAvailable(available: false);
    }
  }
}
