import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/opendroneid_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({Key? key, required this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Timer(const Duration(seconds: 5), checkInternetConnection);
      //checkPermissions();
    }
  }

  @override
  void didChangeDependencies() {
    initPlatformState();
    context.read<StandardsCubit>().fetchAndSetStandards();
    context.read<AircraftCubit>().fetchSavedSettings();
    context.read<SlidersCubit>().fetchAndSetPreference();
    super.didChangeDependencies();
  }

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      await _initPermissionsAndroid();
    } else if (Platform.isIOS) {
      await _initPermissionsIOS();
    } else {
      return;
    }
    if (!mounted) return;
    if (context.read<ShowcaseCubit>().state.showcaseActive) {
      await context.read<OpendroneIdCubit>().stop();
    }
    // check internet connection
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!mounted) return;
        await context
            .read<StandardsCubit>()
            .setInternetAvailable(available: true);
      }
    } on SocketException catch (_) {
      if (!mounted) return;
      await context
          .read<StandardsCubit>()
          .setInternetAvailable(available: false);
    }
  }

  Future<void> _initPermissionsIOS() async {
    final btStatus = await Permission.bluetooth.request();
    if (btStatus.isGranted) {
      if (!mounted) return;
      await context.read<StandardsCubit>().setBluetoothEnabled(enabled: true);
      if (!mounted) return;
      await context.read<OpendroneIdCubit>().isBtTurnedOn().then(
        (value) {
          if (value) context.read<OpendroneIdCubit>().setBtUsed(btUsed: true);
        },
      );
    } else {
      if (!mounted) return;
      await context.read<StandardsCubit>().setBluetoothEnabled(enabled: false);
    }
    final status = await Permission.location.request();
    if (status.isGranted) {
      initLocation();
      if (!mounted) return;
      await context.read<StandardsCubit>().setLocationEnabled(enabled: true);
    } else {
      if (!mounted) return;
      await context.read<StandardsCubit>().setLocationEnabled(enabled: false);
    }
  }

  Future<void> _initPermissionsAndroid() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      if (!mounted) return;
      await context.read<StandardsCubit>().setLocationEnabled(enabled: false);
    } else {
      initLocation();
      if (!mounted) return;
      await context.read<StandardsCubit>().setLocationEnabled(enabled: true);
    }
    final btStatus = await Permission.bluetooth.request();
    // scan makes sense just on android
    final btScanStatus = await Permission.bluetoothScan.request();
    if (btStatus.isGranted && btScanStatus.isGranted) {
      if (!mounted) return;
      await context.read<StandardsCubit>().setBluetoothEnabled(enabled: true);
      if (!mounted) return;
      await context.read<OpendroneIdCubit>().isBtTurnedOn().then(
        (value) {
          if (value) context.read<OpendroneIdCubit>().setBtUsed(btUsed: true);
        },
      );
    } else {
      if (!mounted) return;
      await context.read<StandardsCubit>().setBluetoothEnabled(enabled: false);
    }
    if (!mounted) return;
    await context.read<OpendroneIdCubit>().setWifiUsed(wifiUsed: true);
  }

  void initLocation() {
    final location = Location();
    location.getLocation().then(userLocationChanged);
    location.onLocationChanged.listen(userLocationChanged);
  }

  Future<void> checkPermissions() async {
    final loc = await Permission.location.isGranted;
    // check loc, if was not set before, init listener
    if (!mounted) return;
    if (loc && !context.read<StandardsCubit>().state.locationEnabled) {
      initLocation();
    }
    if (!mounted) return;
    await context.read<StandardsCubit>().setLocationEnabled(enabled: loc);
    final bt = await Permission.bluetooth.isGranted;
    if (!mounted) return;
    await context.read<StandardsCubit>().setBluetoothEnabled(enabled: bt);
  }

  void userLocationChanged(LocationData currentLocation) {
    void updateLoc() {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        context.read<MapCubit>().setUserLocationDouble(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
      }
      // force centering only of first startup
      if (!context.read<MapCubit>().state.wasCenteredOnUser) {
        context.read<MapCubit>().centerToUser();
      }
    }

    // do not set state if showcase is running, would restart it
    if (!context.read<ShowcaseCubit>().state.showcaseActive) {
      setState(updateLoc);
    } else {
      updateLoc();
    }
  }

  Future<void> checkInternetConnection() async {
    // check internet
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!mounted) return;
        await context
            .read<StandardsCubit>()
            .setInternetAvailable(available: true);
      }
    } on SocketException catch (_) {
      await context
          .read<StandardsCubit>()
          .setInternetAvailable(available: false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
