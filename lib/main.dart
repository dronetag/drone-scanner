import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'bloc/aircraft/aircraft_cubit.dart';
import 'bloc/aircraft/selected_aircraft_cubit.dart';
import 'bloc/map/map_cubit.dart';
import 'bloc/opendroneid_cubit.dart';
import 'bloc/screen_cubit.dart';
import 'bloc/showcase_cubit.dart';
import 'bloc/sliders_cubit.dart';
import 'bloc/standards_cubit.dart';
import 'bloc/zones/selected_zone_cubit.dart';
import 'bloc/zones/zones_cubit.dart';
import 'services/location_service.dart';
import 'utils/google_api_key_reader.dart';
import 'utils/uasid_prefix_reader.dart';
import 'widgets/app/app.dart';

const sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: '',
);

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;

/// Runs app with Sentry monitoring (only for production environment)
void runAppWithSentry(void Function() appRunner) async {
  await runZonedGuarded(() async {
    if (sentryDsn == '') {
      print('There is no Sentry DSN specified!');
      appRunner();
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.debug = kDebugMode;
      },
      appRunner: appRunner,
    );
  }, (exception, trace) async {
    print('Unhandled error occurred: $exception $trace');
    await Sentry.captureException(exception, stackTrace: trace);
  });
}

void main() async {
  // init high priority services
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Google services
  await GoogleApiKeyReader.initialize();
  await UASIDPrefixReader.initialize();
  final locationService = LocationService();
  final mapCubit = MapCubit(locationService);
  final selectedCubit = SelectedAircraftCubit();
  final aircraftCubit = AircraftBloc();
  runAppWithSentry(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<StandardsCubit>(
            create: (context) => StandardsCubit(),
            lazy: false,
          ),
          BlocProvider<ScreenCubit>(
            create: (context) => ScreenCubit(),
            lazy: false,
          ),
          BlocProvider<SlidersCubit>(
            create: (context) => SlidersCubit(),
            lazy: false,
          ),
          BlocProvider<MapCubit>(
            create: (context) => mapCubit,
            lazy: false,
          ),
          BlocProvider<ShowcaseCubit>(
            create: (context) => ShowcaseCubit(),
            lazy: false,
          ),
          BlocProvider<ZonesCubit>(
            create: (context) => ZonesCubit(),
            lazy: false,
          ),
          BlocProvider<SelectedZoneCubit>(
            create: (context) => SelectedZoneCubit(),
            lazy: false,
          ),
          BlocProvider<AircraftBloc>(
            create: (context) => aircraftCubit,
            lazy: false,
          ),
          BlocProvider<SelectedAircraftCubit>(
            create: (context) => selectedCubit,
            lazy: false,
          ),
          BlocProvider<OpendroneIdCubit>(
            create: (context) => OpendroneIdCubit(
              mapCubit: mapCubit,
              selectedAircraftCubit: selectedCubit,
              aircraftCubit: aircraftCubit,
            ),
            lazy: false,
          ),
        ],
        child: App(),
      ),
    ),
  );
}
